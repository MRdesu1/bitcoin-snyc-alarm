require 'minitest/autorun'
require 'json'
require 'net/http'
require 'webmock/minitest'
require 'config.yml'


class TestBlockHeight < Minitest::Test
  def setup
    @node_height = 100000
    @explorer_height = 100001
    @explorer_response = @explorer_height.to_s
    @node_response = { 'result' => @node_height }.to_json
    WebMock.stub_request(:post, "http://#{config['rpc_host']}#{config['rpc_port']}")
            .to_return(body: @node_response)
    WebMock.stub_request(:get, config['block_explorer_url']).to_return(body: @block_explorer_response)
  end

  def test_get_block_height
    assert_equal @node_height, get_last_block_from_node(config["RPC_HOST"],config["RPC_USER"],config["RPC_PASSWORD"],config["RPC_PORT"])
    assert_equal @explorer_height, get_last_block_from_explorer(config["EXP_URL"])
  end

  def test_exec_block_diff
    assert_not_equal "OK!", exec_block_diff(@node_height,@explorer_height)
    assert_equal "OK!", exec_block_diff(@node_height + 1,@explorer_height)
  end    
end
