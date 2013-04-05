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
    assert File.directory?("/tmp/static_copy_minitest")
  end

  def test_appends_index_html
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    assert File.exists?("/tmp/static_copy_minitest/foo/bar/index.html")
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  def test_inserts_correctly_in_file
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    assert_match File.read("/tmp/static_copy_minitest/foo/bar/index.html").strip, /hello/
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  def test_other_file_types
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    assert File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  def test_with_ignores
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    refute File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'false' }
    assert_equal response, [ "hello" ]
  end

  def test_not_expired
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    status, headers, response = @middleware.call env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'false' }
    assert_equal response, [ "hello" ]
  end

  def test_expired
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    status, headers, response = @middleware.call env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  def test_expired_without_file_1
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  def test_expired_without_file_2
    @middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    status, headers, response = @middleware.call env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Copy' => 'true' }
    assert_equal response, [ "hello" ]
  end

  #def test_when_error
    #Rack::Static::Copy.stub(:http_headers).raises(Exception)
    #@middleware = Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    #status, headers, response = @middleware.call @default_env
    #assert_equal status, 200
    #assert_equal headers, { 'X-Rack-Static-Load' => 'error' }
    #assert_equal response, ["hello"]
    #Rack::Static::Load.unstub(:http_headers)
  #end

end
