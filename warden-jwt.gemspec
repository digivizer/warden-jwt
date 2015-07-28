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

  spec.add_runtime_dependency 'jwt', '~> 1.5'
  spec.add_runtime_dependency 'rest-client', '~> 1.8'
  spec.add_runtime_dependency 'warden', '~> 1.2'
  spec.add_runtime_dependency 'addressable', '~> 2.3'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rack', '~> 1.6'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.21'
  spec.add_development_dependency 'multi_json', '~> 1.11'
  spec.add_development_dependency 'guard', '~> 2.11'
  spec.add_development_dependency 'guard-rspec', '~> 4.5'
  spec.add_development_dependency 'guard-bundler', '~> 0.1'
end
