# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warden/jwt/version'

Gem::Specification.new do |spec|
  spec.name          = "warden-jwt"
  spec.version       = Warden::JWT::VERSION
  spec.authors       = ["Rob Sharp"]
  spec.email         = ["rob.sharp@digivizer.com"]

  spec.summary       = %q{A Warden strategy for JWT}
  spec.homepage      = "http://github.com/dgvz/warden-jwt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jwt"
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "warden"
  spec.add_runtime_dependency "addressable"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "multi_json"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-bundler"
end
