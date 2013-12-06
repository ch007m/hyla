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
require 'asciidoctor'
require 'eventmachine'
require 'em-websocket'
require 'http/parser'


# internal requires
require 'hyla/logger'
require 'hyla/training'
require 'hyla/configuration'

# extensions
require_all 'hyla/commands'

module Hyla

  def self.logger
    @logger ||= Logger.new
  end

  def self.generate
    @generate ||= Hyla::Commands::Generate.new
  end

  def self.watch
    @watch ||= Hyla::Commands::Watch.new
  end

  def self.reload
    @reload ||= Hyla::Commands::Reload.new
  end

end