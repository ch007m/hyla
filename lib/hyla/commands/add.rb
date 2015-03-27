module Hyla
  module Commands
    class Add < Command

      def self.process(args, options)
        destination = options[:destination] if check_mandatory_option?('-d / --destination', options[:destination])
        artefact_type = options[:artefact_type] if check_mandatory_option?('-a / --artefact_type', options[:artefact_type])
        type = options[:type] if check_mandatory_option?('-t / --type', options[:type])
        font_type = 'liberation'

        copy_fonts(font_type, destination)

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

        Hyla::logger2.info ">>   Artefact #{artefact_file_name} added to project #{destination}"

        case artefact_type
          when 'image','audio','video','source'
           source_dir = [Configuration::samples, artefact_type] * '/'
           FileUtils.cp_r(source_dir,destination)
        end
      end

      #
      # Copy fonts
      #
      def self.copy_fonts(type, destination)
        source = [Configuration::fonts, type] * '/'
        destination = [destination, 'fonts'] * '/'
        destination = File.expand_path destination

        FileUtils.mkdir_p(destination) unless File.exists?(destination)
        FileUtils.cp_r source, destination

        Hyla::logger2.info ">>   Fonts #{type} added to project #{destination}"
      end

    end # class Create
  end # module Commands
end # module Hyla