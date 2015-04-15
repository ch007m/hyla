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

    configs = $options[:config].split(",").map(&:strip) if $options[:config]
    if !configs.empty?
      @yaml_cfg = nil
      configs.each do |config|
        cfg = safe_load_file(config)
        @yaml_cfg = cfg if @yaml_cfg.nil?
        @yaml_cfg = @yaml_cfg.deep_merge(cfg)
      end
    end
    hyla_cfg ||= @yaml_cfg if @yaml_cfg

    log_cfg ||= $options[:log]
    mode ||= hyla_cfg['mode'] if hyla_cfg
    dirname ||= hyla_cfg['dirname'] if hyla_cfg
    logname ||= hyla_cfg['logname'] if hyla_cfg
    level ||= hyla_cfg['level'] if hyla_cfg
    tracer ||= hyla_cfg['tracer'] if hyla_cfg

    $logger2 ||= Logger2.new(mode, log_cfg, dirname, logname, level, tracer)
  end

  def self.safe_load_file(filename)
    f = File.expand_path(filename, $cmd_directory)
    YAML.safe_load_file(f)
  end
end