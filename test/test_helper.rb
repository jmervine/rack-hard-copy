$LOAD_PATH << File.dirname(__FILE__)
if $rake_test
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test"
    add_filter "/vendor"
    add_filter "/coverage"
  end
end

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

