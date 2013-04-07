$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestStaticCopy < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    @default_env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo && echo -n "hello" > /tmp/static_copy_minitest/foo/bar.txt`
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_copy
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'true' }
    assert File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

  def test_copy_expired
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Save' => 'true' }
  end

  def test_copy_no_expiration
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => false)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Save' => 'true' }
  end

  def assert_expected_response call, header
    status, headers, response = call
    assert_equal 200, status
    assert_equal header, headers
    assert_equal [ "hello" ], response
  end
end
