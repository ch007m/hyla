module Hyla
  module Commands
    class Create < Command

      def self.process(args, options)
        destination = options['destination'] if check_mandatory_option?('--d / --destination', options['destination'])
        artefact_type = options['artefact_type'] if check_mandatory_option?('--a / --artefact_type', options['artefact_type'])
        type = options['type'] if check_mandatory_option?('--t / --type', options['type'])

        copy_artefact(type, artefact_type, destination)
      end

      #
      # Copy Artefact to Destination directory
      #
      def self.copy_artefact(type, artefact_type, destination)
        artefact_file_name = type + '_' + artefact_type + Configuration::ADOC_EXT
        source = [Configuration::samples, artefact_file_name] * '/'
        destination = File.expand_path(destination)

        FileUtils.cp(source, destination)

        Hyla::logger.info ">>   Artefact #{artefact_file_name} added to project #{destination}"
      end

    end # class Create
  end # module Commands
end # module Hyla