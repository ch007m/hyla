# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyla/project'

Gem::Specification.new do |s|
  s.name          = 'hyla'
  s.version       = Hyla::VERSION
  s.authors       = ["Charles Mouliard"]
  s.email         = ["ch007m@gmail.com"]
  s.description   = Hyla::DESCRIPTION
  s.summary       = Hyla::SUMMARY
  s.homepage      = "https://github.com/cmoulliard/hyla"
  s.license       = "Apache License 2.0"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'rdoc', '~> 3.11'

  #  Ruby command-line executables
  s.add_runtime_dependency 'commander', '~> 4.1', '>= 4.1.3'
  s.add_runtime_dependency 'asciidoctor', '~> 0.1', '>= 0.1.4'
  s.add_runtime_dependency 'em-websocket', '~> 0.5'
  s.add_runtime_dependency 'multi_json',   '~> 1.8'
  s.add_runtime_dependency 'tilt'
  s.add_runtime_dependency 'haml'
  s.add_runtime_dependency 'slim'
  s.add_runtime_dependency 'guard', '~> 1.8', '>= 1.8.3'
  s.add_runtime_dependency 'listen', '~> 1.3', '>= 1.3.1'
  s.add_runtime_dependency 'safe_yaml', '~> 1.0', '>= 1.0.0'
  s.add_runtime_dependency 'mail', '~> 2.5', '>= 2.5.4'
  s.add_runtime_dependency 'pdfkit', '~> 0.5', '>= 0.5.4'

  # Colorize Text Terminal
  s.add_runtime_dependency 'colorator', '~> 0.1'

end
