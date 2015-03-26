module Hyla
  module Commands
    class New < Command

      @readme_content = <<-EOS
== Readme Asciidoctor Project

This is an empty Asciidoctor readme file.

To create **asciidoc(tor)** content, more info is available http://asciidoctor.org/docs/user-manual[here]

Otherwise, you can add content to this newly project created using the hyla add command :

  hyla add --t asciidoc --a CONTENT  --d PathToProjectCreated

where CONTENT can be an article, book, source, audio, video, table
EOS

      def self.process(args, options = {})

        # out_dir = options[:destination] if self.check_mandatory_option?('-d / --destination', options[:destination])
        out_dir = args.first;

        #
        # Calculate project path (rel/absolute)
        #
        new_project_path = File.expand_path(out_dir, Dir.pwd)

        if Dir.exist? new_project_path

          Hyla.logger.debug("Dir exists: #{new_project_path}")

          # If force is selected, then we delete & recreate it to clean content
          if options[:force]
            Hyla.logger.debug("Force option selected")
            # DOES NOT WORK ON Mac OS X
            # FileUtils.rmdir(new_project_path)
            FileUtils.rm_rf new_project_path
            # Create Directory
            FileUtils.mkdir_p new_project_path
            Hyla.logger.debug("Dir recreated")
          end

          # Preserve content if it exists
          if preserve_content?(new_project_path)
            Hyla.logger.error "Conflict: ", "#{new_project_path} exists and is not empty."
            exit(1)
          end

        else
          # Create Directory when it does not exist
          FileUtils.mkdir_p new_project_path
        end

        #
        # Create blank project
        # or copy sample project from template directory
        #igs
        if options[:blank]
          create_blank_project new_project_path

          # Add yaml config file
          FileUtils.cp_r [Configuration::configs, Configuration::YAML_CONFIG_FILE_NAME] * '/', new_project_path

          # Copy styles
          FileUtils.cp_r Configuration::styles, new_project_path

          Hyla.logger.info("Blank project created")

        else
          raise ArgumentError.new('You must specifiy a template type.') if options[:template_type].nil?

          create_sample_project(new_project_path, options[:template_type])

          # Copy styles
          FileUtils.cp_r Configuration::styles, new_project_path

          Hyla.logger.info("Sample project created using template : #{options[:template_type]}")
        end

      end

      #
      # Create Blank Project
      # with just a readme.adoc file and yaml config file
      def self.create_blank_project(path)
        Dir.chdir(path) do
          f = File.open('readme.adoc', 'w')
          f.puts @readme_content
        end
      end

      #
      # Create a Sample Project
      # from a Template (asciidoc, slideshow)
      # and add styles
      #
      def self.create_sample_project(path, type)
        source = [Configuration::templates, type] * '/' + '/.'
        FileUtils.cp_r source, path

        # Add yaml config file
        FileUtils.cp_r [Configuration::configs, Configuration::YAML_CONFIG_FILE_NAME] * '/', path
      end

      #
      # Preserve source location is folder is not empty
      def self.preserve_content?(path)
        !Dir["#{path}/**/*"].empty?
      end

    end # class
  end # module Commands
end # module Hyla