$LOAD_PATH << File.dirname(__FILE__)
require 'simplecov'
SimpleCov.start

require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/benchmark'

require 'rack/mock'

require 'fileutils'
require 'pry'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each do |file|
  require file
end

