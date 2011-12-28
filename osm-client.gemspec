# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "osm-client"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christoph B\303\274nte"]
  s.date = "2011-12-28"
  s.description = "OpenStreetMap API client for ruby programming language"
  s.email = ["info@christophbuente.de"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md"]
  s.files = ["CHANGELOG", "LICENSE", "Manifest", "README.md", "Rakefile", "osm-client.gemspec"]
  s.homepage = "http://github.com/sozialhelden/osm-client"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Osm-client", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "osm-client"
  s.rubygems_version = "1.8.11"
  s.summary = "OpenStreetMap API client for ruby programming language"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end
