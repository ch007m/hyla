require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'hyla/configuration'
include Log4r

module Hyla
  class Logger2
    
    attr_reader :log, :levels

    def initialize(mode, log_yml_file, dirname = nil, logname = nil, level = nil, tracer = nil)

      #
      # Change logging level within the YAML config file
      # ! Log4r::YamlConfigurator does not allow to change key/val for the level but only for formatter/outputter
      #
      if level.nil? then new_level = 'INFO' else new_level = level end
      if tracer.nil? then new_tracer = 'false' else new_tracer = tracer end
      if mode.nil? then new_mode = 'production' else new_mode = mode end

      log4r_hash = load_file(log_yml_file)

      #
      # TODO - improve it to avoid to hard code path
      #
      log4r_hash['log4r_config']['loggers'].each_with_index do |x, index|
        log4r_hash['log4r_config']['loggers'][index]['level'] = new_level
        log4r_hash['log4r_config']['loggers'][index]['tracer'] = new_tracer
      end

      cfg = Log4r::YamlConfigurator

      if dirname.nil?
        dir = [Dir.home, 'log'] * '/'
        Dir.mkdir(dir) unless Dir.exist?(dir)
        cfg['DIRNAME'] = dir
      else
        cfg['DIRNAME'] = dirname
      end

      if logname.nil? then cfg['LOGNAME'] = 'hyla.log' else cfg['LOGNAME'] = logname end

      cfg.decode_yaml log4r_hash['log4r_config']

      @log = Log4r::Logger[new_mode]
    end

    def levels
      # ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF
      levels = {"ALL" => 0, "DEBUG" => 1, "INFO" => 2, "WARN" => 3, "ERROR" => 4, "FATAL" => 5, "OFF" => 6}
    end

    def iterate(h, level)
      h.each do |k,v|
        value = v || k
        if value.is_a?(Hash) || value.is_a?(Array)
          puts "evaluating: #{value} recursively..."
          iterate(value, level)
        else
          if k == "level"
            v = level
          end
        end
      end
    end

    def nested_hash_value(obj,key)
      if obj.respond_to?(:key?) && obj.key?(key)
        obj[key]
      elsif obj.respond_to?(:each)
        r = nil
        obj.find{ |*a| r=nested_hash_value(a.last,key) }
        r
      end
    end

    def load_file(cfg_file)
      SafeYAML::OPTIONS[:default_mode] = :safe

      if cfg_file.nil?
        f = [Configuration.configs,'log4r.yaml' ] * '/'
      else
        f = cfg_file
      end

      #
      # Find/Replace the logging level
      #
      #content = File.read(f)
      #new_contents = content.gsub(/LOGGING_LEVEL/, level)

      # To merely print the contents of the file, use:
      # puts new_contents

      # To write changes to the file, use:
      #File.open(f, "w") {|file| file.puts new_contents }

      YAML.load_file(f)
    end

    def debug(msg)
      @log.debug msg
    end

    def info(msg)
      @log.info msg
    end

    def warn(msg)
      @log.warn msg
    end

    def error(msg)
      @log.error msg
    end

    def fatal(msg)
      @log.fatal msg
    end

    #
    # topic - the topic of the message, e.g. "Configuration file", "Deprecation", etc.
    # message - the message detail
    #
    # Returns the formatted message
    def message(topic, message)
      formatted_topic(topic) + message.to_s.gsub(/\s+/, ' ')
    end

    #
    # topic - the topic of the message, e.g. "Configuration file", "Deprecation", etc.
    #
    # Returns the formatted topic statement
    def formatted_topic(topic)
      "#{topic} ".rjust(20)
    end

  end

end
