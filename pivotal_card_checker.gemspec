# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pivotal_card_checker/version'

Gem::Specification.new do |spec|
  spec.name          = "pivotal_card_checker"
  spec.version       = PivotalCardChecker::VERSION
  spec.authors       = ["Vlad Kaganyuk", "Forrest Chang"]
  spec.email         = ["vkaganyuk@hedgeye.com"]
  spec.summary       = %q{Checks cards in PivotTracker}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "public_suffix", '~> 1.4.6'
  spec.add_runtime_dependency "tracker_api"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
