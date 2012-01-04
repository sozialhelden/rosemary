#coding:utf-8
require 'rake'
require 'echoe'

Echoe.new('osm-client', '0.1.0') do |p|

 p.description = "OpenStreetMap API client for ruby programming language"
 p.url         = "http://github.com/sozialhelden/osm-client"
 p.author      = ["Christoph Bünte"]
 p.email       = ["info@christophbuente.de"]

 p.retain_gemspec = true

 p.ignore_pattern = %w{
   Gemfile
   Gemfile.lock
   vendor/**/*
   tmp/*
   log/*
   *.tmproj
 }

 p.runtime_dependencies     = [ "httparty", "builder", "oauth" ]
 p.development_dependencies = [ "echoe", "rspec", "webmock" ]
end

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

task :default => :spec