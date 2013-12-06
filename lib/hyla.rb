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
require 'multi_json'
require 'webrick'

# internal requires
require 'hyla/logger'
require 'hyla/training'
require 'hyla/command'
require 'hyla/configuration'
require 'Hyla/WebSocket'
require 'hyla/logger'

# extensions
require_all 'hyla/commands'

module Hyla

  def self.logger
    @logger ||= Logger.new
  end

end