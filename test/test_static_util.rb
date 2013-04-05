$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class TestStaticUtil < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  class MockCopy
    include ::Rack::Static::Util
  end

  def setup
    @mock_copy = MockCopy.new
  end

  def teardown
  end

  def test_without_ignores
    refute @mock_copy.ignored?([], "/foo")
  end

  def test_with_ignores
    assert @mock_copy.ignored?([ "bar", "txt" ], "/foo.txt")
  end

  def test_generate_path_from_index_html
    assert_equal @mock_copy.generate_path_from( "/tmp", "/foo" ), "/tmp/foo/index.html"
  end

  def test_generate_path_from_extention
    assert_equal @mock_copy.generate_path_from( "/tmp", "/foo.txt" ), "/tmp/foo.txt"
  end
end
