module Hyla
  module Commands
    class Create < Command

      def self.process(args, options = {})

          destination = options[:destination]
          artefact_type = options[:artefact_type]
          type = options[:type]

          copy_artefact(type, artefact_type, destination)
      end

      def self.copy_artefact(type, artefact_type, destination)
        artefact_name = type + '_' + artefact_type + Configuration::ADOC_EXT
        source = [Configuration::templates, 'sample', artefact_name] * '/'
        destination = File.expand_path(destination)
        FileUtils.cp(source, destination)
        Hyla::logger.info ">>   Artefact #{artefact_name} added to project #{destination}"
      end

    end # class
  end # module Commands
end # module Hyla