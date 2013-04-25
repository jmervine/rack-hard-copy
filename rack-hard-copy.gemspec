# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/hard/copy'

Gem::Specification.new do |s|
  s.name        = "rack-hard-copy"
  s.version     = Rack::Hard::Copy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine"]
  s.email       = ["joshua@mervine.net"]
  s.homepage    = "http://www.rubyops.net/gems/rack-hard-copy"
  s.summary     = "Rack Middle to creating static copies of rendered endpoints and reload them."
  s.description = s.summary + " It equates to a static file cache with other possible uses. See rubyops.net/gems/rack-hard-copy for details."

  s.add_dependency "rack", "~> 1.5.2"
  s.add_dependency "mime-types", "~> 1.22"

  s.files        = Dir.glob("lib/**/*") + %w(README.md Gemfile)
  s.require_path = 'lib'
end
