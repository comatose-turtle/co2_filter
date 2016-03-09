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
  s.homepage    = "https://github.com/comatose-turtle/co2_filter"
  s.summary     = %q{Uses both collaborative and content-based filtering methods to enable a complex, hybrid recommendation engine.}
  # s.description = "TODO: Description of Co2Filter."
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.0'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end
