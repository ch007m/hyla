# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyla/version'

Gem::Specification.new do |s|
  s.name          = 'hyla'
  s.version       = Hyla::VERSION
  s.authors       = ["Charles Mouliard"]
  s.email         = ["ch007m@gmail.com"]
  s.description   = 'Hyla is an Asciidoctor command line client.'
  s.summary       = 'Hyla is an Asciidoctor command line client.'
  s.homepage      = ""
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'rdoc', '~> 3.11'
  # s.add_development_dependency 'guard', '~> 1.8.3'
  s.add_development_dependency 'listen', '~> 2.0'

  #  Ruby command-line executables
  s.add_runtime_dependency 'commander', '~> 4.1.3'
  s.add_runtime_dependency 'asciidoctor'
  s.add_runtime_dependency 'em-websocket', '~> 0.5'
  s.add_runtime_dependency 'multi_json',   '~> 1.8'

  # Colorize Text Terminal
  s.add_runtime_dependency 'colorator', '~> 0.1'

end
