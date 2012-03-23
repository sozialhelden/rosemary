require 'rspec/core'
require 'rspec/core/rake_task'
require 'webmock/rspec'
RSpec::Core::RakeTask.new(:spec) do |spec|
 spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
 spec.pattern = 'spec/**/*_spec.rb'
 spec.rcov = true
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rosemary.rb"
end

task :c => :console

task :default => :spec

require "bundler/gem_tasks"

