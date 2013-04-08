$LOAD_PATH << File.dirname(__FILE__)
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'minitest/mock'

require 'rack/mock'

require 'fileutils'
require 'pry'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each do |file|
  require file
end

def assert_expected_response call, header
  status, headers, response = call
  assert_equal 200, status
  if header.nil?
    assert_equal( [], headers.each_key.select { |key| key =~ /^X-Rack-Hard-/ } )
  else
    assert headers[header.keys.first] = header.values.first
  end
  assert_equal [ "hello" ], response.body
end
