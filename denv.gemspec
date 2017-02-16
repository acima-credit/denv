# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'denv/version'

Gem::Specification.new do |spec|
  spec.name    = 'denv'
  spec.version = DEnv::VERSION
  spec.authors = ['Adrian Esteban Madrid']
  spec.email   = ['aemadrid@gmail.com']

  spec.summary     = %q{Loads environment variables from .env files and network services into ENV.}
  spec.description = spec.summary
  spec.homepage    = ''
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'multi_json'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3.2'
  spec.add_development_dependency 'vcr', '~> 3.0.3'
end
