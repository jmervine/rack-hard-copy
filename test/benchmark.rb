$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestStaticCopy < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest")
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_benchmark_copy
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_performance_linear 0.9999 do |n| # n is a range value
      n.times do
        @middleware.call env
      end
    end
  end
end
