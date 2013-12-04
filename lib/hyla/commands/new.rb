module Hyla
  module Commands
    class New
      def self.process(args, options = {})
        raise ArgumentError.new('You must specify a path.') if args.empty?

        #
        # Create Directory for the Project
        #
        new_project_path = File.expand_path(args.join(" "), Dir.pwd)
        FileUtils.mkdir_p new_project_path
        if preserve_source_location?(new_project_path, options)
          Hyla.logger.error "Conflict: ", "#{new_project_path} exists and is not empty."
          exit(1)
        end

        #
        # Create blank poject with 2 directories and readme file
        # or copy sample project from template directory
        #
        if options[:blank]
          create_blank_project new_project_path
        else
          raise ArgumentError.new('You must specifiy a template type.') if options[:template_type].nil?
          create_sample_project(new_project_path, options[:template_type])
        end

      end

      #
      # Create Blank Project
      # with just a readme.adoc file and 2 directories
      def self.create_blank_project(path)
        Dir.chdir(path) do
          FileUtils.mkdir(%w(module-a module-b))
          FileUtils.touch("readme.adoc")
        end
      end

      # Create a Sample Project
      # from a Template
      def self.create_sample_project(path, type)
        FileUtils.cp_r templates + '/' + type + '/.', path
      end

      #
      # Preserve source location is folder is not empty and option force is not anable
      def self.preserve_source_location?(path, options)
        !options[:force] && !Dir["#{path}/**/*"].empty?
      end

      # Template Location
      def self.templates
        File.expand_path("../../templates", File.dirname(__FILE__))
      end

    end
  end
end