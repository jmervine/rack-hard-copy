$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestHardCopy < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @environment = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    @options     = { :store => "/tmp/static_copy_minitest", :headers => true }
    `mkdir -p /tmp/static_copy_minitest/foo && echo 'hello' > /tmp/static_copy_minitest/foo/bar.txt`
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_when_default_timeout
    middleware = Rack::Hard::Copy.new(MockApp.new, @options)
    assert_equal 'true', middleware.call(@environment).headers['X-Rack-Hard-Load']
  end

  def test_when_expired
    middleware = Rack::Hard::Copy.new(MockApp.new, @options.merge(:timeout => 0))
    assert_equal 'true', middleware.call(@environment).headers['X-Rack-Hard-Save']
  end

  def test_when_not_expired
    middleware = Rack::Hard::Copy.new(MockApp.new, @options.merge(:timeout => 600))
    assert_equal 'true', middleware.call(@environment).headers['X-Rack-Hard-Load']
  end
end
