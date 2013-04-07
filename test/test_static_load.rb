$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestStaticLoad < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @default_env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    Rack::Static::Copy.new(MockApp.new, :store => "/tmp/static_copy_minitest").call(@default_env)
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_when_no_copy
    assert_expected_response @middleware.call(@default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })), { 'X-Rack-Static-Load' => 'false' }
  end

  def test_when_copy
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'true' }
  end

  def test_when_ignored
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'false' }
  end

  def test_when_not_ignored
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "foo" ], :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'true' }
  end

  # def test_when_headers is used as part of testing above,
  # and therefore omitted

  def test_when_not_headers
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    assert_expected_response @middleware.call(@default_env), {}

    assert_expected_response @middleware.call(@default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })), {}
  end

  def test_when_expired
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 0, :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'false' }
  end

  def test_when_not_expired
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 600, :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Static-Load' => 'true' }
  end

  def assert_expected_response call, header
    status, headers, response = call
    assert_equal 200, status
    assert_equal header, headers
    assert_equal [ "hello" ], response
  end

end
