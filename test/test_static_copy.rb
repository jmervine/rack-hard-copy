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
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_init_creates_static_directory
    Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    assert ::File.directory?("/tmp/static_copy_minitest"), "failed to created directory"
  end

  def test_appends_index_html
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
    assert File.exists?("/tmp/static_copy_minitest/foo/bar/index.html"), "failed to created file"
  end

  def test_inserts_correctly_in_file
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
    assert_match File.read("/tmp/static_copy_minitest/foo/bar/index.html").strip, /hello/
  end

  def test_other_file_types
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
    assert File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

  def test_with_ignores
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'false' }
    refute File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

  def test_not_expired
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'false' }
  end

  def test_expired
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
  end

  def test_expired_without_file_1
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
  end

  def test_expired_without_file_2
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Static-Copy' => 'true' }
  end

  def test_without_headers
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), nil
  end
end
