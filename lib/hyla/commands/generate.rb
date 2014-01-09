module Hyla
  module Commands
    class Generate < Command

      def self.process(args, options = {})

        rendering = options[:rendering] if self.check_mandatory_option?('--r / --rendering', options[:rendering])

        case rendering
          when 'toc2adoc'

            Hyla.logger.info "Rendering : Table of Content to Asciidoc"
            self.check_mandatory_option?('--t / --toc', options[:toc])
            @toc_file = options[:toc]
            @out_dir = options[:destination]
            @project_name = options[:project_name]

            self.table_of_content_to_asciidoc(@toc_file, @out_dir, @project_name)

          when 'adoc2html'

            Hyla.logger.info "Rendering : Asciidoc to HTML"
            self.check_mandatory_option?('--s / --source', options[:source])
            self.check_mandatory_option?('--d / --destination', options[:destination])

            @destination = options[:destination]
            @source = options[:source]

            # Check Style to be used
            new_asciidoctor_option = {
                :attributes => {
                    'stylesheet' => self.check_style(options[:style])
                }
            }

            merged_options = Configuration[options].deep_merge(new_asciidoctor_option)

            extensions = 'adoc|ad|asciidoc'

            self.asciidoc_to_html(@source, @destination, extensions, merged_options)

          when 'index2slide'
            Hyla.logger.info "Rendering : Asciidoctor Indexed Files to SlideShow"
            self.check_mandatory_option?('--s / --source', options[:source])
            self.check_mandatory_option?('--d / --destination', options[:destination])

            @destination = options[:destination]
            @source = options[:source]

            new_asciidoctor_option = {
                :template_dirs => [ self.backend_dir(options[:backend]) ],
                :attributes => {
                    'stylesheet' => self.check_style(options[:style])
                }
            }

            merged_options = Configuration[options].deep_merge(new_asciidoctor_option)

            # Extension(s) of the files containing include directives
            extensions = 'txt'

            self.asciidoc_to_html(@source, @destination, extensions, merged_options)

          when 'adoc2slide'
            Hyla.logger.info "Rendering : Asciidoc to SlideShow"
            self.check_mandatory_option?('--s / --source', options[:source])
            self.check_mandatory_option?('--d / --destination', options[:destination])

            @destination = options[:destination]
            @source = options[:source]

            new_asciidoctor_option = {
                :template_dirs => [ self.backend_dir(options[:backend]) ],
                :attributes => {
                    'stylesheet' => self.check_style(options[:style])
                }
            }

            merged_options = Configuration[options].deep_merge(new_asciidoctor_option)

            # Extension(s) of the files to be parsed
            extensions = 'adoc|ad|asciidoc'

            self.asciidoc_to_html(@source, @destination, extensions, merged_options)
          else
            Hyla.logger.error ">> Unknow rendering"
            exit(1)
        end
      end

      # Return backend directory
      # containing templates (haml, slim)
      def self.backend_dir(backend)
        case backend
          when 'deckjs'
            return [Configuration::backends, 'haml', 'deckjs'] * '/'
          when 'revealjs'
            return [Configuration::backends, 'slim', 'revealjs'] * '/'
        end
      end

      def self.asciidoc_to_html(source, destination, extensions, options)

        # Move to Source directory & Retrieve Asciidoctor files to be processed
        source = File.expand_path source
        @destination = File.expand_path destination

        Hyla.logger.info ">>       Source dir: #{source}"
        Hyla.logger.info ">>  Destination dir: #{@destination}"

        # Exit if source directory does not exist
        if !Dir.exist? source
          Hyla.logger.error ">> Source directory does not exist"
          exit(1)
        end

        Dir.chdir(source)
        current_dir = Dir.pwd
        Hyla.logger.info ">>       Current dir: #{current_dir}"

        # Delete destination directory
        FileUtils.rm_rf(Dir.glob(@destination))

        # Search for files using extensions parameter and do the rendering
        adoc_file_paths = []
        Find.find(current_dir) do |path|
          if path =~ /.*\.(?:#{extensions})$/
            path1 = Pathname.new(source)
            path2 = Pathname.new(path)
            relative_path = path2.relative_path_from(path1).to_s
            Hyla.logger.debug ">>       Relative path: #{relative_path}"
            adoc_file_paths << relative_path

            # Create dir
            html_dir = @destination + '/' + File.dirname(relative_path)
            Hyla.logger.info ">>        Dir of html: #{html_dir}"
            FileUtils.mkdir_p html_dir

            # Copy Resources for Slideshow
            case options[:backend]
              when 'deckjs'
                # Copy css, js files to destination directory
                self.cp_resources_to_dir(File.dirname(html_dir), 'deck.js')
              when 'revealjs'
                self.cp_resources_to_dir(File.dirname(html_dir), 'revealjs')
            end

            # Render asciidoc to HTML
            Hyla.logger.info ">> File to be rendered : #{path}"
            options[:to_dir] = html_dir
            Asciidoctor.render_file(path, options)

          end
        end

        # No asciidoc files retrieved
        if adoc_file_paths.empty?
          Hyla.logger.info "     >>   No asciidoc files retrieved."
          exit(1)
        end

      end

      #
      # CSS Style to be used
      # Default is : asciidoctor.css
      #
      def self.check_style(style)
        if !style.nil?
          css_file = [style, '.css'].join()
        else
          css_file = 'asciidoctor.css'
        end
      end

      #
      # Copy resources to target dir
      def self.cp_resources_to_dir(path, resource)
        source = [Configuration::resources, resource] * '/'
        destination = [path, resource] * '/'
        FileUtils.cp_r source, destination
      end

      #
      # Method parsing TOC File to generate directories and files
      # Each Level 1 entry will become a directory
      # and each Level 2 a file created under the directory
      #
      # @param [File Containing the Table of Content] toc_file
      # @param [Directory where asciidoc files will be generated] out_dir
      # @param [Project name used to create parent of index files] project_name
      #
      def self.table_of_content_to_asciidoc(toc_file, out_dir, project_name)

        Hyla.logger.info '>> Project Name : ' + project_name + ' <<'

        # Open file & parse it
        f = File.open(toc_file, 'r')

        # Expand File Path
        @out_dir = File.expand_path out_dir

        # Re Create Directory of generated content
        if Dir.exist? @out_dir
          FileUtils.rm_rf @out_dir
          FileUtils.mkdir_p @out_dir
        else
          FileUtils.mkdir_p @out_dir
        end

        # Copy YAML Config file
        FileUtils.cp_r [Configuration::templates, Configuration::YAML_CONFIG_FILE_NAME] * '/', @out_dir

        # Copy styles
        FileUtils.cp_r Configuration::styles, @out_dir

        #
        # Move to 'generated' directory as we will
        # create content relative to this directory
        #
        Dir.chdir @out_dir
        @out_dir = Pathname.pwd

        # Create index file of all index files
        @project_index_file = self.create_index_file(project_name, Configuration::LEVEL_1)


        # File iteration
        f.each do |line|

          #
          # Check level 1
          # Create a directory where its name corresponds to 'Title Level 1' &
          # where we have removed the leading '=' symbol and '.' and
          # replaced ' ' by '_'
          #
          if line[/^=\s/]

            # Create File
            dir_name = remove_special_chars(2, line)
            new_dir = [@out_dir, dir_name].join('/')
            Hyla.logger.info '>> Directory created : ' + new_dir + ' <<'
            FileUtils.mkdir_p new_dir
            Dir.chdir(new_dir)

            # Add image, audio, video directory
            self.create_asset_directory(['image', 'audio', 'video'])

            #
            # Create an index file
            # It is used to include files belonging to a module and will be used for SlideShows
            # The file created contains a title (= Dir Name) and header with attributes
            #
            @index_file = create_index_file(dir_name, Configuration::LEVEL_1)

            # Include index file created to parent index file
            @project_index_file.puts Configuration::INCLUDE_PREFIX + dir_name + '/' + dir_name + Configuration::INDEX_SUFFIX + Configuration::INCLUDE_SUFFIX
            @project_index_file.puts "\n"

            # Move to next line record
            next
          end

          #
          # Check Level 2
          # Create a file for each Title Level 2 where name corresponds to title (without '==' symbol) &
          # where we have removed the leading '==' symbol  and '.' and replace ' ' by '_'
          #
          if line[/^==\s/]

            # Close File created previously if it exists
            if !@previous_f.nil?
              @previous_f.close
            end

            # Create File
            f_name = remove_special_chars(3, line)
            Hyla.logger.info '   # File created : ' + f_name.to_s
            f_name += '.adoc'
            @new_f = File.new(f_name, 'w')
            @new_f.puts Configuration::HEADER
            @new_f.puts "\n"

            @previous_f = @new_f

            # Include file to index
            @index_file.puts Configuration::INCLUDE_PREFIX + f_name + Configuration::INCLUDE_SUFFIX
            @index_file.puts "\n"
          end

          #
          # Add Content to file if it exists and line does not start with characters to be skipped
          #
          if !@new_f.nil? and !line.start_with?(Configuration::SKIP_CHARACTERS)
            @new_f.puts line
          end

        end

      end

      #
      # Create Asset Directory
      #
      def self.create_asset_directory(assets = [])
        assets.each do |asset|
          Dir.mkdir(asset) if !Dir.exist? asset
        end
      end

      #
      # Remove space, dot from a String
      #
      def self.remove_special_chars(pos, text)
        return text[pos, text.length].strip.gsub(/\s/, '_').gsub('.', '')
      end

      #
      # Add '/' at the end of the target path
      # if the target path provided doesn't contain it
      #
      def self.check_slash_end(out_dir)
        last_char = out_dir.to_s[-1, 1]
        Hyla.logger.info '>> Last char : ' + last_char
        if !last_char.equal? '/\//'
          temp_dir = out_dir.to_s
          out_dir = temp_dir + '/'
        end
        out_dir
      end

      #
      # Create ascidoc index file
      # containing references to asciidoc files part of a module
      #
      def self.create_index_file(file_name, level)
        n_file_name = file_name + Configuration::INDEX_SUFFIX
        index_file = File.new(n_file_name, 'w')

        index_file.puts Configuration::HEADER_INDEX
        index_file.puts "\n"
        # TODO - until now we cannot use level 0 for parent/children files
        # even if doctype: book
        # This is why the level for each index file title is '=='
        index_file.puts '==' + file_name
        index_file.puts "\n"

        index_file
      end

      #
      # Check mandatory options
      #
      def self.check_mandatory_option?(key, value)
        if value.nil? or value.empty?
          Hyla.logger.warn "Mandatory option missing: #{key}"
          exit(1)
        else
          true
        end
      end

    end # class
  end # module Commands
end # module Hyla