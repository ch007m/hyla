# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hyla/project'

Gem::Specification.new do |s|
  s.name          = 'hyla'
  s.version       = Hyla::VERSION
  s.authors       = ["Charles Moulliard"]
  s.email         = ["ch007m@gmail.com"]
  s.description   = Hyla::DESCRIPTION
  s.summary       = Hyla::SUMMARY
  s.homepage      = "https://github.com/cmoulliard/hyla"
  s.license       = "Apache License 2.0"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'font-awesome-sass','~> 4.3'
  s.add_development_dependency 'compass', '~> 1.0'
  s.add_development_dependency 'sass', '~> 3.4'

  #  Ruby command-line executables
  # Add pry before
  s.add_runtime_dependency 'asciidoctor', '~> 0.1'
  s.add_runtime_dependency 'coderay', '~> 1.0'
  s.add_runtime_dependency 'commander', '~> 4.2', '>= 4.2.0'
  s.add_runtime_dependency 'em-websocket', '~> 0.5'
  s.add_runtime_dependency 'eventmachine', '~> 1.0'
  s.add_runtime_dependency 'ffi', '~> 1.9'
  s.add_runtime_dependency 'guard', '~> 1.8'
  s.add_runtime_dependency 'imgkit', '~> 1.4'
  s.add_runtime_dependency 'haml', '~> 4.0'
  s.add_runtime_dependency 'highline', '~> 1.6'
  s.add_runtime_dependency 'listen', '~> 1.3'
  s.add_runtime_dependency 'lumberjack', '~> 1.0'
  s.add_runtime_dependency 'mail', '~> 2.5'
  s.add_runtime_dependency 'method_source', '~> 0.8'
  s.add_runtime_dependency 'multi_json', '~> 1.8'
  s.add_runtime_dependency 'pry', '~> 0.9', '< 0.10.0'
  s.add_runtime_dependency 'rdoc', '~> 3.12'
  s.add_runtime_dependency 'safe_yaml', '~> 1.0'
  s.add_runtime_dependency 'slim', '~> 2.0'
  s.add_runtime_dependency 'slop', '~> 3.4'
  s.add_runtime_dependency 'temple', '~> 0.6'
  s.add_runtime_dependency 'tilt', '~> 1.4'
  s.add_runtime_dependency 'thor', '~> 0.18'
  s.add_runtime_dependency 'wkhtmltopdf-binary', '~> 0.9'

  # Colorize Text Terminal
  s.add_runtime_dependency 'colorator', '~> 0.1'

end
