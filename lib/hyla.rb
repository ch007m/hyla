$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

# rubygems
require 'rubygems'

# 3rd party
require 'colorator'
require 'listen'
require 'guard'
require 'safe_yaml'
require 'asciidoctor'
require 'asciidoctor/backends/html5'

# Added to fix issue with Ruby 2.0 on Windows machine
require 'em/pure_ruby'

require 'eventmachine'
require 'em-websocket'
require 'http/parser'
require 'multi_json'
require 'webrick'
require 'find'
require 'mail'
require 'mime/types'
require 'slim'
require 'imgkit'

# internal requires
require 'hyla/logger'
require 'hyla/core_ext'
require 'hyla/command'
require 'hyla/configuration'
require 'hyla/websocket'
require 'hyla/logger'
require 'hyla/logger2'

# extensions
require_all 'hyla/commands'

module Hyla

  def self.logger
    @logger ||= Logger.new
  end

  def self.logger2
    log_cfg ||=  $options[:log]

    hyla_cfg = safe_load_file($options[:config]) if $options[:config]

    mode ||= hyla_cfg['mode']
    dirname ||= hyla_cfg['dirname']
    logname ||= hyla_cfg['logname']
    level ||= hyla_cfg['level']
    tracer ||= hyla_cfg['tracer']

    $logger2 ||= Logger2.new(mode, log_cfg, dirname, logname, level, tracer)
  end

  def self.safe_load_file(filename)
    f = File.expand_path(filename, $cmd_directory)
    YAML.safe_load_file(f)
  end
end