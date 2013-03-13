# -*- encoding: utf-8 -*-
require File.expand_path("../lib/stethoscope/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "stethoscope"
  s.version     = Stethoscope::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Daniel Neighman']
  s.email       = ['has.sox@gmail.com']
  s.homepage    = "http://github.com/hassox/stethoscope"
  s.summary     = "Heartbeat middleware for responding to heartbeat pings"
  s.description = "Heartbeat middleware for responding to heartbeat pings"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "stethoscope"

  s.add_dependency              "rack",          ">  1.0"
  s.add_dependency              "dictionary",    ">= 1.0"
  s.add_dependency              "tilt",          ">= 1.0"

  s.add_development_dependency  "bundler",     ">= 1.0.0"
  s.add_development_dependency  "rspec-core",  ">= 2.0.0.beta.20"
  s.add_development_dependency  "nanotest"
  s.add_development_dependency  "nanotest_extensions"
  s.add_development_dependency  "rake"
  s.add_development_dependency  "rack-test"
  s.add_development_dependency  'json_pure'


  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
