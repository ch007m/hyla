require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require 'hyla/configuration'
include Log4r

module Hyla
  class Logger2
    
    attr_reader :log, :levels

    def initialize(name, log_yml_file, dirname = nil, logname = nil, level = nil)
      log4r_f = load_file(log_yml_file)

      cfg = Log4r::YamlConfigurator

      if dirname.nil?
        dir = [Dir.home, 'log'] * '/'
        Dir.mkdir(dir) unless Dir.exist?(dir)
        cfg['DIRNAME'] = dir
      else
        cfg['DIRNAME'] = dirname
      end

      if logname.nil?
        cfg['LOGNAME'] = 'hyla.log'
      else
        cfg['LOGNAME'] = logname
      end

      if level.nil?
        cfg['LOGGING_LEVEL'] = 'INFO'
      else
        cfg['LOGGING_LEVEL'] = levels[level]
      end

      cfg.decode_yaml log4r_f['log4r_config']
      cfg['hyla'] = 'Hyla Logger'

      @log = Log4r::Logger[name]
    end

    def levels
      # ALL < DEBUG < INFO < WARN < ERROR < FATAL < OFF
      levels = {"ALL" => 0, "DEBUG" => 1, "INFO" => 2, "WARN" => 3, "ERROR" => 4, "FATAL" => 5, "OFF" => 6}
    end

    def load_file(cfg_file)
      SafeYAML::OPTIONS[:default_mode] = :safe
      if cfg_file.nil?
        YAML.load_file([Configuration.configs,'log4r.yaml' ] * '/')
      else
        YAML.load_file(cfg_file)
      end
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
