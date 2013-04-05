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
    status, headers, response = @middleware.call @default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'false' }
    assert_equal response, ["hello"]
  end

  def test_when_copy
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'true' }
    assert_equal response, ["hello"]
  end

  def test_when_ignored
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'false' }
    assert_equal response, ["hello"]
  end

  def test_when_not_ignored
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "foo" ], :headers => true)
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'true' }
    assert_equal response, ["hello"]
  end

  # def test_when_headers is used as part of testing above,
  # and therefore omitted

  def test_when_not_headers
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, {}
    assert_equal response, ["hello"]

    status, headers, response = @middleware.call @default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })
    assert_equal status, 200
    assert_equal headers, {}
    assert_equal response, ["hello"]
  end

  def test_when_expired
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 0, :headers => true)
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'false' }
    assert_equal response, ["hello"]
  end

  def test_when_not_expired
    @middleware = Rack::Static::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 600, :headers => true)
    status, headers, response = @middleware.call @default_env
    assert_equal status, 200
    assert_equal headers, { 'X-Rack-Static-Load' => 'true' }
    assert_equal response, ["hello"]
  end

end
