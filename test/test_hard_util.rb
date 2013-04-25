$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestHardUtil < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  class MockSave
    include ::Rack::Hard::Util
  end

  def setup
    @mock_copy = MockSave.new
  end

  def teardown
    ::File.delete("/tmp/foo.txt") if ::File.exists?("/tmp/foo.txt")
  end

  def test_ignores?
    refute @mock_copy.ignored?([], "/foo")
    assert @mock_copy.ignored?([ "bar", "txt" ], "/foo.txt")
  end

  def test_generate_path_from
    assert_equal @mock_copy.generate_path_from( "/tmp", "/foo" ), "/tmp/foo/index.html"
    assert_equal @mock_copy.generate_path_from( "/tmp", "/foo.txt" ), "/tmp/foo.txt"
  end

  def test_expired?
    `touch /tmp/foo.txt`
    assert @mock_copy.expired?(0, "/tmp/foo.txt")
    refute @mock_copy.expired?(600, "/tmp/foo.txt")
  end

  def test_expired_without_file
    ::File.delete("/tmp/foo.txt") if ::File.exists?("/tmp/foo.txt")
    assert @mock_copy.expired?(0, "/tmp/foo.txt")
    assert @mock_copy.expired?(600, "/tmp/foo.txt")
  end
end
