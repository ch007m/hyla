module Hyla
  class Configuration < Hash

    attr_reader :HEADER, :INDEX_SUFFIX, :HEADER_INDEX, :INCLUDE_PREFIX, :INCLUDE_SUFFIX, :LEVEL_1, :LEVEL_2, :SKIP_CHARACTERS,
                :ADOC_EXT, :PREFIX_ARTEFACT, :YAML_CONFIG_FILE_NAME, :DEFAULTS,
                :templates, :cover_template, :samples, :resources, :styles, :fonts, :backends, :assets

    DEFAULTS = {
        'source' => Dir.pwd,
        'destination' => File.join(Dir.pwd, 'generated_content'),
        'watch_dir' => '.',
        'watch_ext' => %w(ad adoc asc asciidoc txt index),

        # Asciidoctor
        'backend' => 'html5',
        'eruby' => 'erb',
        'doctype' => 'article',
        'compact' => false,
        'to_dir' => '.',
        'to_file' => '',
        'attributes' => {
            'source-highlighter' => 'coderay',
            'linkcss!' => 'true',
            'data-uri' => 'true',
            'stylesheet' => 'asciidoctor.css',
            'stylesdir' => 'styles'
        },
        'safe' => 'unsafe',
        'header_footer' => true
    }

    #
    # Matches an include preprocessor directive.
    #
    # Examples
    #
    #   include::chapter1.ad[]
    #   include::example.txt[lines=1;2;5..10]
    #
    IncludeDirectiveRx = /^\\?include::([^\[]+)\[(.*?)\]$/

    INCLUDE_PREFIX = 'include::'

    INCLUDE_SUFFIX = '[]'

    INDEX_SUFFIX = '_AllSlides.txt'

    INDEX_FILE = 'AllSlides.txt'

    SNIPPET_TAG = 'snippet'


    #    OLD HEADER_TXT used with hyla < 1.0.7
    #    HEADER_TXT = ":data-uri:\n" +
    #        ":icons: font\n" +
    #        ":last-update-label!:\n" +
    #        ":source-highlighter: coderay\n"
    #
    #    HEADER_TXT = "ifndef::local[]\n" +
    #                 ":imagesdir: ../image/\n" +
    #                 "endif::[]\n"


    HEADER_TXT = "// Asciidoctor attributes\n"

    LEVEL_1 = '= '

    LEVEL_2 = '== '

    SKIP_CHARACTERS = '>>'

    #ADOC_EXT = '.ad'
    ADOC_EXT = '.adoc'

    PREFIX_ARTEFACT = 'asciidoc_'

    YAML_CONFIG_FILE_NAME = '_config.yaml'


    #
    # Cover Slim Template
    #
    def self.cover_template
      File.expand_path(COVER_TEMPLATE, File.dirname(__FILE__))
    end

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
    # Fonts Location
    #
    def self.fonts
      File.expand_path(FONTS, File.dirname(__FILE__))
    end

    #
    # Assets Location
    #
    def self.assets
      File.expand_path(ASSETS, File.dirname(__FILE__))
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
    # options with anything in _config.yaml, and adding the given options on top.
    #
    # override - A Hash of options that override any options in both
    #            the defaults and the config file. See Hyla::Configuration::DEFAULTS for a
    #            list of option names and their defaults.
    #
    # Returns the final configuration Hash.
    def self.parse(override)

      # Extract Asciidoctor attributes received from hyla command line '-a key=value,key=value'
      # Convert them to a Hash of attributes 'attributes' => { 'backend' => html5 ... }
      # Assign hash to override[:attributes]
      extracted_attributes = self.extract_attributes(override[:attributes]) if override[:attributes]
      override[:attributes] = extracted_attributes if extracted_attributes

      extracted_email_attributes = self.extract_attributes(override[:email_attributes]) if override[:email_attributes]
      override[:email_attributes] = extracted_email_attributes if extracted_email_attributes

      # Stringify keys of the hash that we receive from Hyla
      override = Configuration[override].stringify_keys
      Hyla::logger.debug("OVERRIDE Keys: #{override.inspect}")

      # Clone DEFAULTS
      config = DEFAULTS
      Hyla::logger.debug("DEFAULTS Keys: #{config.inspect}")

      #
      # Read the config file passed as parameter if it exists
      # otherwise read default _config.yaml file if it exists and
      # merge content with DEFAULT config
      #
      alt_config = read_config_file(override['config']) if override['config']
      if !alt_config.nil?
        config = config.deep_merge(alt_config)
      else
        new_config = read_config_file(YAML_CONFIG_FILE_NAME)
        Hyla::logger.debug("OVERRIDE Keys: #{new_config.inspect}") if !new_config.nil?
        config = config.deep_merge(new_config) if !new_config.nil?
      end

      # Merge DEFAULTS < _config.yaml or your_config.yaml file < override
      config = config.deep_merge(override)
      # Convert String Keys to Symbols Keys
      config = Configuration[].transform_keys_to_symbols(config)
      Hyla::logger.debug("Merged Keys: #{config.inspect}")
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
      Hyla::logger.warn "No configuration file retrieved for the name : #{filename}"
    end

    #
    # Load Safely YAML File
    #
    def self.safe_load_file(filename)
      YAML.safe_load_file(filename)
    end

    #
    # Retrieve asciidoctor attributes
    # Could be an Arrays of Strings key=value,key=value
    # or
    # Could be a Hash (DEFAULTS, CONFIG_File)
    def self.extract_attributes(attributes)
      result = attributes.split(',')
      attributes = Hash.new
      result.each do |entry|
        words = entry.split('=')
        attributes[words[0]] = words[1]
      end
      return attributes
    end

    # Public: Turn all keys into string
    #
    # Return a copy of the hash where all its keys are strings
    def stringify_keys
      reduce({}) { |hsh, (k, v)| hsh.merge(k.to_s => v) }
    end

    #
    # Take keys of hash and transform those to a symbols
    #
    def transform_keys_to_symbols(hash)
      return hash if not hash.is_a?(Hash)
      hash.inject({}) { |result, (key, value)|
        new_key = case key
                    when String then
                      key.to_sym
                    else
                      key
                  end
        new_value = case value
                      when Hash
                        if key.eql? 'attributes'
                          value
                        else
                          transform_keys_to_symbols(value)
                        end
                      else
                        value
                    end
        result[new_key] = new_value
        result
      }
    end
    
    ASSETS = '../../lib/resources/assets'

    TEMPLATES = '../../lib/templates'

    RESOURCES = '../../lib/resources'

    SAMPLES = '../../lib/templates/sample'

    STYLES = '../../lib/resources/styles'

    FONTS = '../../lib/resources/fonts'

    BACKENDS = '../../lib/resources/backends'

    COVER_TEMPLATE = '../../lib/resources/cover.slim'

    ASSESSMENT_TXT = File.open(self.resources + '/course/assessment.txt','r').read

    LABS_TXT = File.open(self.resources + '/course/labinstructions.txt','r').read

    INDEX = File.open(self.resources + '/course/index.txt','r').read

    HEADER_INDEX = File.open(self.resources + '/course/header_index.txt','r').read

    FOOTER_TXT = File.open(self.resources + '/course/footer.txt','r').read

    COVER_TXT = File.open(self.resources + '/course/cover.txt','r').read

    OBJECTIVES_TXT = File.open(self.resources + '/course/objectives.txt','r').read

    SUMMARY_TXT = File.open(self.resources + '/course/summary.txt','r').read

    AUDIO_TXT = File.open(self.resources + '/course/audio.txt','r').read

  end # Class Configuration
end # module Hyla