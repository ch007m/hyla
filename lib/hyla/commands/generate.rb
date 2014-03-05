# encoding: utf-8
module Hyla
  module Commands
    class Generate < Command

      def self.process(args, options = {})

        rendering = options[:rendering] if self.check_mandatory_option?('-r / --rendering', options[:rendering])

        case rendering

          when 'toc2adoc'

            Hyla.logger.info "Rendering : Table of Content to Asciidoc"
            self.check_mandatory_option?('-t / --toc', options[:toc])
            self.check_mandatory_option?('-d / --destination', options[:destination])

            @toc_file = options[:toc]
            @out_dir = options[:destination]
            @project_name = options[:project_name] if options[:project_name]
            @project_name = 'My Project' if !options[:project_name]

            self.table_of_content_to_asciidoc(@toc_file, @out_dir, @project_name)

          when 'adoc2html'

            Hyla.logger.info "Rendering : Asciidoc to HTML"
            self.check_mandatory_option?('-s / --source', options[:source])
            self.check_mandatory_option?('-d / --destination', options[:destination])

            @destination = options[:destination]
            @source = options[:source]

            # Check Style to be used
            new_asciidoctor_option = {
                :template_dirs => [self.backend_dir(options[:backend])],
                :attributes => {
                    'stylesheet' => self.check_style(options[:style])
                }
            }

            merged_options = Configuration[options].deep_merge(new_asciidoctor_option)

            extensions = 'adoc|ad|asciidoc'

            self.asciidoc_to_html(@source, @destination, extensions, merged_options)

          when 'index2html'
            Hyla.logger.info "Rendering : Asciidoctor Indexed Files to SlideShow"
            self.check_mandatory_option?('-s / --source', options[:source])
            self.check_mandatory_option?('-d / --destination', options[:destination])

            @destination = options[:destination]
            @source = options[:source]

            new_asciidoctor_option = {
                :template_dirs => [self.backend_dir(options[:backend])],
                :attributes => {
                    'stylesheet' => self.check_style(options[:style])
                }
            }

            merged_options = Configuration[options].deep_merge(new_asciidoctor_option)

            # Extension(s) of the files containing include directives
            extensions = 'txt'

            self.asciidoc_to_html(@source, @destination, extensions, merged_options)

          when 'html2pdf'

            Hyla.logger.info "Rendering : Generate PDF from HTML file"

            source_dir = options[:source] if self.check_mandatory_option?('-s / --source', options[:source])
            out_dir = options[:destination] if self.check_mandatory_option?('-d / --destination', options[:destination])

            file_name = options[:file]
            cover_path = options[:cover_path]
            header_html_path = options[:header_html_path]
            footer_text = options[:footer_text]

            self.html_to_pdf(file_name, source_dir, out_dir, footer_text, header_html_path, cover_path)

          when 'cover2png'

            Hyla.logger.info "Rendering : Generate Cover HTML page & picture - format png"

            out_dir = options[:destination] if self.check_mandatory_option?('-d / --destination', options[:destination])
            file_name = options[:cover_file]
            image_name = options[:cover_image]

            # Configure Slim engine
            slim_file = Configuration::cover_template
            slim_tmpl = File.read(slim_file)
            template = Slim::Template.new(:pretty => true) { slim_tmpl }

            # Do the Rendering HTML
            parameters = {:course_name => options[:course_name],
                          :module_name => options[:module_name],
                          :image_path  => options[:image_path]}
            res = template.render(Object.new, parameters)

            unless Dir.exist? out_dir
              FileUtils.mkdir_p out_dir
            end

            Dir.chdir(out_dir) do
              out_file = File.new(file_name, 'w')
              out_file.puts res
              out_file.puts "\n"

              # Do the Rendering Image
              kit = IMGKit.new(res, quality: 90, width: 950, height: 750)
              kit.to_img(:png)
              kit.to_file(image_name)

              # Convert HTML to Image
              # system ("wkhtmltoimage -f 'png' #{file_name} #{image_name}")
            end

          else
            Hyla.logger.error ">> Unknow rendering"
            exit(1)
        end
      end

      #
      # Return backend directory
      # containing templates (haml, slim)
      #
      def self.backend_dir(backend)
        case backend
          when 'deckjs'
            return [Configuration::backends, 'haml', 'deckjs'] * '/'
          when 'revealjs'
            return [Configuration::backends, 'slim', 'revealjs'] * '/'
          when 'html5'
            return [Configuration::backends, 'slim', 'html5'] * '/'
          else
            return [Configuration::backends, 'slim', 'html5'] * '/'
        end
      end

      #
      # Call Asciidoctor.render function
      #
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

        # Move to source directory
        Dir.chdir(source)
        current_dir = Dir.pwd
        Hyla.logger.info ">>       Current dir: #{current_dir}"

        #
        # Backup Asciidoctor attributes
        # Strange issue discovered
        #
        @attributes_bk = options[:attributes]

        # Delete destination directory (generated_content, ...)
        # FileUtils.rm_rf(Dir.glob(@destination))

        # Search for files using extensions parameter and do the rendering
        adoc_file_paths = []
        Find.find(current_dir) do |f|
          if f =~ /.*\.(?:#{extensions})$/

            path_to_source = Pathname.new(source)
            path_to_adoc_file = Pathname.new(f)
            relative_path = path_to_adoc_file.relative_path_from(path_to_source).to_s
            Hyla.logger.debug ">>       Relative path: #{relative_path}"
            adoc_file_paths << relative_path

            # Get asciidoc file name
            file_name_processed = path_to_adoc_file.basename

            #
            # Create destination dir relative to the path calculated
            #
            html_dir = @destination + '/' + File.dirname(relative_path)
            Hyla.logger.info ">>        Dir of html: #{html_dir}"
            FileUtils.mkdir_p html_dir

            # Copy Fonts
            self.cp_resources_to_dir(File.dirname(html_dir), 'fonts')

            # Copy Resources for Slideshow
            case options[:backend]
              when 'deckjs'
                # Copy css, js files to destination directory
                self.cp_resources_to_dir(File.dirname(html_dir), 'deck.js')
              when 'revealjs'
                self.cp_resources_to_dir(File.dirname(html_dir), 'revealjs')
            end

            # Render asciidoc to HTML
            Hyla.logger.info ">> File to be rendered : #{f}"

            # Convert asciidoc file name to html file name
            html_file_name = file_name_processed.to_s.gsub(/.adoc$|.ad$|.asciidoc$|.index$|.txt$/, '.html')
            options[:to_dir] = html_dir
            options[:to_file] = html_file_name
            options[:attributes] = @attributes_bk
            Asciidoctor.render_file(f, options)

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

        #
        # Create destination directory if it does not exist
        unless Dir.exist? @out_dir
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
            FileUtils.mkdir new_dir
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

            #
            # Generate a Module key value
            # 01, 02, ...
            # that we will use as key to create the asciidoc file
            #
            dir_name = File.basename(Dir.getwd)
            @module_key = dir_name.initial.rjust(2, '0')
            Hyla.logger.info ">> Module key : #@module_key <<"

            #
            # Reset counter value used to generate file number
            # for the file 01, 00
            #
            @index = 0

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

            #
            # Replace special characters form the file and
            # add the module key followed by the index value for the file
            # Example : m01p01_MyTitle.ad, m01p02_Another_Title.ad
            #
            f_name = remove_special_chars(3, line)
            @index += 1
            #file_index = @index.to_s.initial.rjust(2, '0')
            file_index = sprintf('%02d', @index)
            f_name = 'm' + @module_key + 'p' + file_index + '_' + f_name + '.ad'

            Hyla.logger.info '   # File created : ' + f_name.to_s

            #
            # Create File and add configuration HEADER
            #
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

=begin
      #
      # Generate PDF
      #
      def self.html_to_pdf(source, destination, html_file_name)
        file_path = [source, html_file_name] * '/'
        html_file = File.new(file_path)
        kit = PDFKit.new(html_file,
                         :page_size => 'A4',
                         :toc => true,
                         :page_offset => 1,
                         :footer_center => 'Page [page]')

        # Create destination directory if it does not exist
        unless File.directory?(destination)
          FileUtils.mkdir_p(destination)
        end

        # Save PDF to a file
        pdf_file_name = [destination, html_file_name.sub(/html|htm/, 'pdf')] * '/'
        kit.to_file(pdf_file_name)
        Hyla.logger.info ">> PDF file generated and saved : #{pdf_file_name} "
      end
=end

      def self.html_to_pdf(file_name, source, destination, footer_text, header_html_path, cover_path)

        destination= File.expand_path destination
        pdf_file = [destination, "result.pdf"] * '/'
        wkhtml_cmd = "wkhtmltopdf"
        size = 'A4'

        # pdf_file_name = [destination, html_file_name.sub(/html|htm/, 'pdf')] * '/'

        list_of_files = ""

        unless File.directory?(destination)
          FileUtils.mkdir_p(destination)
        end

        if file_name.nil? || file_name.empty?
          filter = [source] * '/' + "*.html"
          files = Dir[filter]

          files.each do |file|
            file_name = File.basename file
            next if file_name.include?('assessments')
            next if file_name.include?('labinstructions')
            next if file_name.include?('title')
            file = File.expand_path file
            list_of_files = list_of_files + " " + file
          end
        else
          list_of_files = [File.expand_path(source), file_name] * '/'
        end

        wkhtml_cmd.concat " #{list_of_files} #{pdf_file}"
        wkhtml_cmd.concat " --margin-top '18mm' --header-html '#{header_html_path}'" if !header_html_path.nil? || !header_html_path.empty?
        wkhtml_cmd.concat " --margin-bottom '10mm'  --footer-center '#{footer_text}'" if !footer_text.nil? || !footer_text.empty?
        wkhtml_cmd.concat " --cover '#{cover_path}'" if !cover_path.nil? || !cover_path.empty?

        Dir.chdir(source) do
          system "#{wkhtml_cmd} --page-size #{size}"
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
        index_file.puts '== ' + file_name
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
