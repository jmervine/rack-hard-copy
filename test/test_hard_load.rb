$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestHardLoad < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @default_env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest").call(@default_env)
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_when_no_copy
    assert_expected_response @middleware.call(@default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })), { 'X-Rack-Hard-Load' => 'false' }
  end

  def test_when_copy
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Hard-Load' => 'true' }
  end

  def test_when_not_get
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    assert_equal [ 200, {}, ["hello"] ], @middleware.call(@default_env.merge('REQUEST_METHOD' => 'POST'))
  end

  def test_when_ignored
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    assert_equal [ 200, {}, ["hello"] ], @middleware.call(@default_env)
  end

  def test_when_not_ignored
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "foo" ], :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Hard-Load' => 'true' }
  end

  # def test_when_headers is used as part of testing above,
  # and therefore omitted

  def test_when_not_headers
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    assert_expected_response @middleware.call(@default_env), nil

    assert_expected_response @middleware.call(@default_env.merge({ 'PATH_INFO' => '/foo/bah.txt' })), nil
  end

  def test_when_expired
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 0, :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Hard-Load' => 'false' }
  end

  def test_when_not_expired
    @middleware = Rack::Hard::Load.new(MockApp.new, :store => "/tmp/static_copy_minitest", :timeout => 600, :headers => true)
    assert_expected_response @middleware.call(@default_env), { 'X-Rack-Hard-Load' => 'true' }
  end
end
