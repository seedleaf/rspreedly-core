# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'rspreedly_core/version'

Gem::Specification.new do |s|
  s.name        = 'rspreedly-core'
  s.version     = RspreedlyCore::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jonathan Greenberg', 'Lake Denman']
  s.email       = ['greenberg@entryway.net', 'lake@entryway.net']
  s.homepage    = ''
  s.summary     = %q{Spreedly Core api wrapper written in ruby.}
  s.description = %q{Spreedly Core api wrapper written in ruby.}

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables   = `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'httparty', '0.7.7'

  s.add_development_dependency 'rspec', '~> 2.3.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'mocha', '~> 0.9.12'
  s.add_development_dependency 'bundler', '~> 1.0.10'
  s.add_development_dependency 'rcov', '~> 0.9.9'
  s.add_development_dependency 'ruby-debug', '~> 0.10.4'
end
