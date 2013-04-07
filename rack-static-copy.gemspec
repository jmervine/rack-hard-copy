# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/static/copy'

Gem::Specification.new do |s|
  s.name        = "rack-static-copy"
  s.version     = Rack::Static::Copy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine"]
  s.email       = ["joshua@mervine.net"]
  s.homepage    = "http://www.rubyops.net/gems/rack-static-copy"
  s.summary     = "Rack Middle to creating static copies of rendered endpoints."
  s.description = s.summary + " This should allow for you to server your content via nginx or the like, without having to rerender."

  #s.add_development_dependency "simplecov"
  #s.add_development_dependency "yard"

  s.add_dependency "rack", ">=1.5.2"
  s.add_dependency "mime-types", ">=1.22"

  s.files        = Dir.glob("lib/**/*") + %w(README.md Gemfile)
  s.require_path = 'lib'
end
