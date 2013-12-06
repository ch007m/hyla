module Hyla
  module Commands
    class Create < Command

      def self.process(args, options = {})

          @config = Hyla::Configuration.new

          destination = options[:destination]
          artefact_type = options[:artefact_type]
          type = options[:type]

          copy_artefact(type, artefact_type, destination)
      end

      def self.copy_artefact(type, artefact_type, destination)
        artefact_name = type + '_' + artefact_type + @config.ADOC_EXT
        source = [@config.LOC_ARTEFACT, artefact_name] * '/'
        destination = [destination] * '/'
        FileUtils.cp(source, destination)
      end

    end # class
  end # module Commands
end # module Hyla