$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestBenchmarks < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @opts = { :store => "/tmp/static_copy_minitest" }
    @env  = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }

    `mkdir -p /tmp/static_copy_minitest/foo && echo "hello" > /tmp/static_copy_minitest/foo/bar.txt`
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_benchmark_copy_save
    @copy = Rack::Hard::Copy.new(MockApp.new, @opts.merge(:timeout => 0))
    assert_performance_linear 0.9 do |n|
      n.times do
        @copy.call @env
      end
    end
  end

  def test_benchmark_copy_load
    @copy = Rack::Hard::Copy.new(MockApp.new, @opts.merge(:timeout => 600))
    assert_performance_linear 0.9 do |n|
      n.times do
        @copy.call @env
      end
    end
  end

  def test_benchmark_save
    @save = Rack::Hard::Save.new(MockApp.new, @opts)
    assert_performance_linear 0.9 do |n|
      n.times do
        @save.call @env
      end
    end
  end

  def test_benchmark_load
    @load = Rack::Hard::Load.new(MockApp.new, @opts)
    assert_performance_linear 0.9 do |n|
      n.times do
        @load.call @env
      end
    end
  end
end
