module Hyla
  class Training
    def initialize(config)
      self.config = config.clone
      self.source = File.expand_path(config['source'])
      self.dest = File.expand_path(config['destination'])
    end

    # Public: Generate HTML5 from Asciidoctor files (Training) to output.
    #
    # Returns nothing.
    def process
      self.generate
    end

    #
    # Generate
    #
    def generate
      # Here is where we will call AsciiDoctor
      Hyla.logger.info 'Transforming Asciidoc files'
    end

  end
end