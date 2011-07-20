lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

require "gas/version"

Gem::Specification.new do |s|
  s.name = "gas"
  s.version = Gas::Version
  s.authors = "Fredrik Wallgren"
  s.email = "fredrik.wallgren@gmail.com"
  s.homepage = "https://github.com/walle/gas"
  s.summary = ""
  s.description = "..."

  s.rubyforge_project = s.name

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.textile LICENSE]

  s.add_dependency 'thor', '~> 0.14.6'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rr'
  s.add_development_dependency 'bundler'

  s.files = Dir.glob("{bin,lib,spec,config}/**/*") + ['LICENSE', 'README.textile']
  s.executables = ['gas']
  s.require_path = ['lib']
end

