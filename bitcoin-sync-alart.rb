require 'json'
require 'net/http'
require 'uri'
require 'yaml'

config = YAML.load_file("config.yml")

# ノードからheightを取得
def get_last_block_from_node(rpc_host,rpc_user,rpc_password,rpc_port)
  uri = URI("http://#{rpc_host}:#{rpc_port}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri)
  req.basic_auth rpc_user, rpc_password
  req.content_type = 'application/json'
  req.body = { jsonrpc: '2.0', method: 'getblockcount' }.to_json
  response = http.request(req)
  return JSON.parse(response.body)["result"]
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


node_height = get_last_block_from_node(config["rpc_host"],config["rpc_user"],config["rpc_password"],config["rpc_port"])
exp_height = get_last_block_from_explorer(config["exp_url"])
puts exec_block_diff(node_height.to_i,exp_height.to_i)

