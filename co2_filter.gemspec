# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "co2_filter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "co2_filter"
  s.version     = Co2Filter::VERSION
  s.authors     = ["Tommy Orr"]
  s.email       = ["torr@pivotal.io"]
  s.homepage    = ""
  s.summary     = %q{Uses both collaborative and content-based filtering methods to enable a complex, hybrid recommendation engine.}
  # s.description = "TODO: Description of Co2Filter."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
