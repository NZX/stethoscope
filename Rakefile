require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Run all tests'
task :test do
  test_path = File.join(File.expand_path(File.dirname(__FILE__)), "test")
  $:.unshift test_path
  require 'test_helper'

  require 'test_stethoscope'
end
