# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rosemary/version"

Gem::Specification.new do |s|
  s.name = "rosemary"
  s.version = Rosemary::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph Bünte, Enno Brehm"]
  s.date = "2012-03-22"
  s.description = "OpenStreetMap API client for ruby"
  s.email = ["info@christophbuente.de"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "lib/changeset_callbacks.rb", "lib/hash.rb", "lib/rosemary/api.rb", "lib/rosemary/basic_auth_client.rb", "lib/rosemary/changeset.rb", "lib/rosemary/element.rb", "lib/rosemary/errors.rb", "lib/rosemary/member.rb", "lib/rosemary/node.rb", "lib/rosemary/oauth_client.rb", "lib/rosemary/parser.rb", "lib/rosemary/relation.rb", "lib/rosemary/tags.rb", "lib/rosemary/user.rb", "lib/rosemary/way.rb", "lib/rosemary.rb"]
  s.homepage = "https://github.com/sozialhelden/openstreetmap"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "OpenStreetMap", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "rosemary"
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
