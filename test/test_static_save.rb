$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestHardSave < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def setup
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
  end

  def teardown
    FileUtils.rm_rf "/tmp/static_copy_minitest"
  end

  def test_init_creates_static_directory
    Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    assert ::File.directory?("/tmp/static_copy_minitest"), "failed to created directory"
  end

  def test_appends_index_html
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
    assert File.exists?("/tmp/static_copy_minitest/foo/bar/index.html"), "failed to created file"
  end

  def test_inserts_correctly_in_file
    env = { 'PATH_INFO' => '/foo/bar', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
    assert_match File.read("/tmp/static_copy_minitest/foo/bar/index.html").strip, /hello/
  end

  def test_other_file_types
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
    assert File.exists?("/tmp/static_copy_minitest/foo/bar.txt")
  end

  def test_when_not_get
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'POST' }
    assert_equal [ 200, {}, ["hello"] ], @middleware.call(env)
  end

  def test_with_ignores
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :ignores => [ "txt" ], :headers => true)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_equal [ 200, {}, ["hello"] ], @middleware.call(env)
  end

  def test_not_expired
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'false' }
  end

  def test_expired
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    `mkdir -p /tmp/static_copy_minitest/foo/ && touch /tmp/static_copy_minitest/foo/bar.txt`
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
  end

  def test_expired_without_file_1
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 600)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
  end

  def test_expired_without_file_2
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest", :headers => true, :timeout => 0)
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), { 'X-Rack-Hard-Save' => 'true' }
  end

  def test_without_headers
    @middleware = Rack::Hard::Save.new(MockApp.new, :store => "/tmp/static_copy_minitest")
    env = { 'PATH_INFO' => '/foo/bar.txt', 'REQUEST_METHOD' => 'GET' }
    assert_expected_response @middleware.call(env), nil
  end
end
