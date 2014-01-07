module Hyla
  class Configuration < Hash

    attr_reader :HEADER, :INDEX_SUFFIX, :HEADER_INDEX, :INCLUDE_PREFIX, :INCLUDE_SUFFIX, :LEVEL_1, :LEVEL_2, :SKIP_CHARACTERS,
                :ADOC_EXT, :PREFIX_ARTEFACT, :YAML_CONFIG_FILE_NAME, :DEFAULTS,
                :templates, :samples, :resources, :styles, :backends

    DEFAULTS = {
        'source' => Dir.pwd,
        'destination' => File.join(Dir.pwd, 'generated_content'),

        'backend' => 'html5'
    }

    INCLUDE_PREFIX = 'include::'

    INCLUDE_SUFFIX = '[]'

    INDEX_SUFFIX = '_AllSlides.index'

    HEADER = ":data-uri:\n" +
        ":icons: font\n" +
        ":last-update-label!:\n" +
        ":source-highlighter: coderay\n" +
        ":toc: left\n" +
        "\n"

    HEADER_INDEX = ":data-uri:\n" +
        ":navigation:\n" +
        ":menu:\n" +
        ":status:\n" +

        "\n"

    LEVEL_1 = '= '

    LEVEL_2 = '== '

    SKIP_CHARACTERS = '>>'

    ADOC_EXT = '.adoc'

    PREFIX_ARTEFACT = 'asciidoc_'

    TEMPLATES = '../../lib/templates'

    RESOURCES = '../../lib/resources'

    SAMPLES = '../../lib/templates/sample'

    STYLES = '../../lib/resources/styles'

    BACKENDS = '../../lib/resources/backends'

    YAML_CONFIG_FILE_NAME = '_config.yml'

    #
    # Templates Location
    #
    def self.templates
      File.expand_path(TEMPLATES, File.dirname(__FILE__))
    end

    #
    # Resources Location
    #
    def self.resources
      File.expand_path(RESOURCES, File.dirname(__FILE__))
    end

    #
    # Stylesheets Location
    #
    def self.styles
      File.expand_path(STYLES, File.dirname(__FILE__))
    end

    #
    # Backends Location
    #
    def self.backends
      File.expand_path(BACKENDS, File.dirname(__FILE__))
    end

    #
    # Samples Location
    #
    def self.samples
      File.expand_path(SAMPLES, File.dirname(__FILE__))
    end

    # Public: Generate a Hyla configuration Hash by merging the default
    # options with anything in _config.yml, and adding the given options on top.
    #
    # override - A Hash of options that override any options in both
    #            the defaults and the config file. See Hyla::Configuration::DEFAULTS for a
    #            list of option names and their defaults.
    #
    # Returns the final configuration Hash.
    def self.parse(override)
      config = DEFAULTS
      override = Configuration[override].stringify_keys
      new_config = read_config_file(YAML_CONFIG_FILE_NAME)
      config = config.deep_merge(new_config) if ! new_config.nil?

      # Merge DEFAULTS < _config.yml < override
      config = config.deep_merge(override)
      # Convert String Keys to Symbols Keys
      config = Configuration[].transform_keys_to_symbols(config)
      return config
    end

    #
    # Read YAML Config file
    #
    def self.read_config_file(filename)
      f = File.expand_path(filename)
      Hyla::logger.info("Config file to be parsed : #{f}")
      config = safe_load_file(f)
      config
    rescue SystemCallError
      Hyla::logger.warn "No _config.yaml file retrieved"
    end

    #
    # Load Safely YAML File
    #
    def self.safe_load_file(filename)
      YAML.safe_load_file(filename)
    end

    # Public: Turn all keys into string
    #
    # Return a copy of the hash where all its keys are strings
    def stringify_keys
      reduce({}) { |hsh,(k,v)| hsh.merge(k.to_s => v) }
    end

    #take keys of hash and transform those to a symbols
    def transform_keys_to_symbols(value)
      return value if not value.is_a?(Hash)
      hash = value.inject({}){|memo,(k,v)| memo[k.to_sym] = self.transform_keys_to_symbols(v); memo}
      return hash
    end

  end # Class Configuration
end # module Hyla