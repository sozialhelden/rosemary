# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "open_street_map/version"

Gem::Specification.new do |s|
  s.name = "open_street_map"
  s.version = OpenStreetMap::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph B\u{fc}nte, Enno Brehm"]
  s.date = "2012-03-22"
  s.description = "OpenStreetMap API client for ruby"
  s.email = ["info@christophbuente.de"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "lib/changeset_callbacks.rb", "lib/hash.rb", "lib/open_street_map/api.rb", "lib/open_street_map/basic_auth_client.rb", "lib/open_street_map/changeset.rb", "lib/open_street_map/element.rb", "lib/open_street_map/errors.rb", "lib/open_street_map/member.rb", "lib/open_street_map/node.rb", "lib/open_street_map/oauth_client.rb", "lib/open_street_map/parser.rb", "lib/open_street_map/relation.rb", "lib/open_street_map/tags.rb", "lib/open_street_map/user.rb", "lib/open_street_map/way.rb", "lib/open_street_map.rb"]
  s.homepage = "https://github.com/sozialhelden/openstreetmap"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "OpenStreetMap", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "open_street_map"
  s.rubygems_version = "1.8.10"

  s.summary = "OpenStreetMap API client for ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end
