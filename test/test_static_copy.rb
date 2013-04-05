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

  def test_init_creates_static_directory
    Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    assert File.directory?("/tmp/static_copy_minitest")
  end

  def test_appends_index_html
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    @middleware.call env
    assert File.exists?("/tmp/static_copy_minitest/foo/bar/index.html")
  end

  def test_inserts_correctly_in_file
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    @middleware.call env
    assert_match File.read("/tmp/static_copy_minitest/foo/bar/index.html").strip, /hello/
  end

  def test_other_file_types
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    @middleware.call env
    assert File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

  def test_with_ignores
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ])
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    @middleware.call env
    refute File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

end
