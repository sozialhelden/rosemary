require 'rspec/core'
require 'rspec/core/rake_task'
require 'webmock/rspec'
RSpec::Core::RakeTask.new(:spec) do |spec|
 spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rosemary.rb"
end

task :c => :console

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end

require "bundler/gem_tasks"

