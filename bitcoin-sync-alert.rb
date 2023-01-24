require 'json'
require 'net/http'
require 'uri'
require 'yaml'


# ノードからheightを取得
def get_last_block_from_node(rpc_host,rpc_user,rpc_password,rpc_port)
  uri = URI("http://#{rpc_host}:#{rpc_port}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri)
  req.basic_auth rpc_user, rpc_password
  req.content_type = 'application/json'
  req.body = { jsonrpc: '2.0', method: 'getblockcount' }.to_json
  response = http.request(req)

  return JSON.parse(response.body)["result"].to_i
end

# エクスプローラーサイトからheightを取得
def get_last_block_from_explorer(explorer_url)
  res = Net::HTTP.get(URI(explorer_url))
  return res.to_i
end

def exec_block_diff(node_height,exp_height)
  diff = node_height - exp_height
  # ブロック差異が3以上の場合はエラーとする
  if diff.abs >= 3
    return "NG! Node:" + node_height.to_s + " explorer:" + exp_height.to_s
  else
    return "OK! Node:" + node_height.to_s + " explorer:" + exp_height.to_s
  end
end

def post_slack(webhook_url,alert_message)
  uri = URI("#{webhook_url}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri)
  req.content_type = 'application/json'
  req.body = { text: alert_message }.to_json
  response = http.request(req)
end

config = YAML.load_file("config.yml")
node_height = get_last_block_from_node(config["RPC_HOST"],config["RPC_USER"],config["RPC_PASSWORD"],config["RPC_PORT"])
exp_height = get_last_block_from_explorer(config["EXP_URL"])
diff_result = exec_block_diff(node_height,exp_height)
post_slack(config["WEBHOOK_URL"],diff_result)

