# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "openstreetmap"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph B\u{fc}nte"]
  s.date = "2012-01-25"
  s.description = "OpenStreetMap API client for ruby"
  s.email = ["info@christophbuente.de"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "lib/changeset_callbacks.rb", "lib/hash.rb", "lib/open_street_map/api.rb", "lib/open_street_map/basic_auth_client.rb", "lib/open_street_map/changeset.rb", "lib/open_street_map/element.rb", "lib/open_street_map/errors.rb", "lib/open_street_map/node.rb", "lib/open_street_map/oauth_client.rb", "lib/open_street_map/relation.rb", "lib/open_street_map/tags.rb", "lib/open_street_map/user.rb", "lib/open_street_map/way.rb", "lib/openstreetmap.rb"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README.md", "Rakefile", "lib/changeset_callbacks.rb", "lib/hash.rb", "lib/open_street_map/api.rb", "lib/open_street_map/basic_auth_client.rb", "lib/open_street_map/changeset.rb", "lib/open_street_map/element.rb", "lib/open_street_map/errors.rb", "lib/open_street_map/node.rb", "lib/open_street_map/oauth_client.rb", "lib/open_street_map/relation.rb", "lib/open_street_map/tags.rb", "lib/open_street_map/user.rb", "lib/open_street_map/way.rb", "lib/openstreetmap.rb", "openstreetmap.gemspec", "spec/open_street_map/changeset_spec.rb", "spec/open_street_map/node_spec.rb", "spec/open_street_map/way_spec.rb", "spec/open_street_map_changeset_spec.rb", "spec/open_street_map_node_spec.rb", "spec/open_street_map_way_spec.rb"]
  s.homepage = "https://github.com/sozialhelden/openstreetmap"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Openstreetmap", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "openstreetmap"
  s.rubygems_version = "1.8.15"
  s.summary = "OpenStreetMap API client for ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end
