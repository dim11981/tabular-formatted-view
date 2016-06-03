# encoding: utf-8

require 'rubygems'
require(File.expand_path('../lib/version.rb',__FILE__))

Gem::Specification.new do |s|
  s.name        = 'tabular-formatted-view'
  s.version     = Viewing::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'tabular-formatted-view lib'
  s.description = 'View some data in simple color tabular form in Windows console'
  s.authors     = ['Dmitriy Mullo']
  s.email       = ['d.a.mullo1981@gmail.com']
  s.homepage    = 'https://github.com/dim11981/tabular-formatted-view'
  s.platform = Gem::Platform::RUBY
  s.files       = Dir['*.md']+Dir['tabular-formatted-view.*']+Dir['lib/*.rb']+Dir['test/*.rb']+Dir['fixtures/*']
  s.require_path = 'lib'

  s.add_dependency 'kernel32lib', '~> 0.0', '>= 0.0.2'
end
