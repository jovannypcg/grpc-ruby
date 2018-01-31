# -*- ruby -*-
# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'grpc-demo'
  s.version       = '1.0.0'
  s.authors       = ['Jovanny Cruz']
  s.email         = 'jovanny.cruz@crowdflower.com'
  s.homepage      = ''
  s.summary       = 'gRPC Ruby demo'
  s.description   = 'Simple demo of using gRPC from Ruby'

  s.files         = `git ls-files -- protocol/*`.split("\n")
  s.executables   = `git ls-files -- protocol/*.rb`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ['lib']
  s.platform      = Gem::Platform::RUBY

  s.add_dependency 'grpc', '~> 1.0'
  s.add_dependency 'bunny', '>= 2.8.0'
  s.add_dependency 'pry-nav', '~> 0.2.4'

  s.add_development_dependency 'bundler', '~> 1.7'
end
