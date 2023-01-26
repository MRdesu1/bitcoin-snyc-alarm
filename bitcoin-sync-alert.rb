require 'json'
require 'net/http'
require 'uri'
require 'yaml'

config_file = ENV['HOME'] + "/bitcoin-sync-alerm/config.yml"
config = YAML.load_file(config_file)

RETRY_MAX_COUNT=config["RETRY_MAX_COUNT"]
RETRY_WAIT_TIME=config["RETRY_WAIT_TIME"]

# ノードからheightを取得
def get_last_block_from_node(rpc_host,rpc_user,rpc_password,rpc_port)
  uri = URI("http://#{rpc_host}:#{rpc_port}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri)
  req.basic_auth rpc_user, rpc_password
  req.content_type = 'application/json'
  req.body = { jsonrpc: '2.0', method: 'getblockcount' }.to_json
  retry_count = 0
  begin
    response = http.request(req)
  rescue => e
    if retry_count < RETRY_MAX_COUNT
      sleep RETRY_WAIT_TIME
      puts "NODE retry count: #{retry_count += 1}"
      retry
    else
      puts e.message
      exit
    end
  end
  return JSON.parse(response.body)["result"].to_i
end

# エクスプローラーサイトからheightを取得
def get_last_block_from_explorer(explorer_url)
  retry_count = 0
  begin
    res = Net::HTTP.get(URI(explorer_url))
  rescue => e
    if retry_count < RETRY_MAX_COUNT
      sleep RETRY_WAIT_TIME
      puts "EXPLORER retry count: #{retry_count += 1}"
      retry
    else
      puts e.message
      exit
    end
  end
  return res.to_i
end


def exec_block_diff(node_height,exp_height,interval_threshold)
  diff = node_height - exp_height
  # ブロック差異が3以上の場合はエラーとする
  if diff.abs >= interval_threshold
    return "NG! Node:" + node_height.to_s + " explorer:" + exp_height.to_s
  else
    return "OK"
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


node_height = get_last_block_from_node(config["RPC_HOST"],config["RPC_USER"],config["RPC_PASSWORD"],config["RPC_PORT"])
exp_height = get_last_block_from_explorer(config["EXP_URL"])
diff_result = exec_block_diff(node_height,exp_height,config["INTERVAL_THRESHOLD"])
if diff_result != "OK"
  post_slack(config["WEBHOOK_URL"],diff_result)
end
