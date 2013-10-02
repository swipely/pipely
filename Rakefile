#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'cane/rake_task'

RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/**/*_spec.rb'
end

Cane::RakeTask.new(:quality) do |cane|
    cane.canefile = '.cane'
end

task :default => [:spec, :quality]
