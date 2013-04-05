$LOAD_PATH << File.dirname(__FILE__)
require 'rake/testtask'

Rake::TestTask.new do |t|
  $rake_test = true
  t.pattern = "test/test_*.rb"
end

Rake::TestTask.new "bench" do |t|
  t.pattern = "test/benchmark.rb"
end


