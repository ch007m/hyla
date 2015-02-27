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
            @image_path = options[:image_path] if options[:image_path]

            self.table_of_content_to_asciidoc(@toc_file, @out_dir, @project_name, @image_path)

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

            extensions = 'adoc,ad,asciidoc'
            excludes = 'lab_assets|lab_assets_solution|code|snippets|templates|generated_content|generated_content_instructor|generated_content_snippet|generated_slideshow|generated_content_pdf|generated_content_students'

            self.asciidoc_to_html(@source, @destination, extensions, excludes, merged_options)

          when 'index2html'
            Hyla.logger.info "Rendering : Asciidoctor Indexed Files to HTML"
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

            #
            # Extension(s) of the files containing include directives
            #
            extensions = 'txt'
            excludes = 'lab_assets|lab_assets_solution|code|snippets|templates|generated_content|generated_content_instructor|generated_content_snippet|generated_slideshow|generated_content_pdf|generated_content_students'

            self.asciidoc_to_html(@source, @destination, extensions, excludes, merged_options)

          when 'html2pdf'

            Hyla.logger.info "Rendering : Generate PDF from HTML file"

            source_dir = options[:source] if self.check_mandatory_option?('-s / --source', options[:source])
            out_dir = options[:destination] if self.check_mandatory_option?('-d / --destination', options[:destination])

            file_name = options[:file]
            cover_path ||= options[:cover_path]
            header_html_path = options[:header_html_path]
            footer_text = options[:footer_text]

            self.html_to_pdf(file_name, source_dir, out_dir, footer_text, header_html_path, cover_path)

          when 'cover2png'

            Hyla.logger.info "Rendering : Generate Cover HTML page & picture - format png"

            out_dir = options[:destination] if self.check_mandatory_option?('-d / --destination', options[:destination])
            file_name = options[:cover_file]
            image_name = options[:cover_image]
            course_name = options[:course_name]
            module_name = options[:module_name]
            bg_image_path = options[:image_path]

            self.cover_img(out_dir, file_name, image_name, course_name, module_name, bg_image_path)

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
      # Cover Function
      # Create a png file using the HTML generated with the Slim cover template
      #
      def self.cover_img(out_dir, file_name, image_name, course_name, module_name, bg_image_path)

        unless Dir.exist? out_dir
          FileUtils.mkdir_p out_dir
        end

        # Configure Slim engine
        slim_file = Configuration::cover_template
        slim_tmpl = File.read(slim_file)
        template = Slim::Template.new(:pretty => true) { slim_tmpl }

        # Replace underscore with space
        course_name = course_name.gsub('_', ' ')
        # Replace underscore with space, next digits & space with nothing & Capitalize
        module_name = module_name.gsub('_', ' ').gsub(/^\d{1,2}\s/, '').capitalize

        Hyla.logger.debug "Module name : " + module_name

        # Do the HTML Rendering
        parameters = {:course_name => course_name,
                      :module_name => module_name,
                      :image_path => bg_image_path}
        res = template.render(Object.new, parameters)

        #
        # Create the cover file and do the rendering of the image
        #
        Dir.chdir(out_dir) do
          out_file = File.new(file_name, 'w')
          out_file.puts res
          out_file.puts "\n"

          # Do the Rendering Image
          kit = IMGKit.new(res, quality: 90, width: 950, height: 750)
          kit.to_img(:png)
          kit.to_file(image_name)
        end

      end

      #
      # Call Asciidoctor.render function
      #
      def self.asciidoc_to_html(source, destination, extensions, excludes, options)

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

        adoc_file_paths = []

        #
        # Search for files into the current directory using extensions parameter as filter key
        # Reject directory specified and do the rendering
        #
        files = Dir[current_dir + "/**/*.{" + extensions + "}"].reject { |f| f =~ /\/#{excludes}\// }

        #
        # Check if snippet parameter is defined
        # as we have to modify the AllSlides.txt file
        # to include within the brackets this tag --> [tag=snippet]
        #
        if options[:snippet_content] == true
          files.each do |f|
            add_tag_to_index_file(f)
          end
        end

        files.each do |f|
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
          # TODO : Verify if we still need to do that as the FONTS liberation have been moved
          # TODO : under local lib directory of revealjs
          # self.cp_resources_to_dir(File.dirname(html_dir), 'fonts')

          # Copy Resources for Slideshow
          case options[:backend]
            when 'deckjs'
              # Copy css, js files to destination directory
              self.cp_resources_to_dir(File.dirname(html_dir), 'deck.js')
            when 'revealjs'
              self.cp_resources_to_dir(File.dirname(html_dir), 'revealjs')
          end

          #
          # Render asciidoc to HTML
          #
          Hyla.logger.info ">> File to be rendered : #{file_name_processed}"

          #
          # Convert asciidoc file name to html file name
          #
          html_file_name = file_name_processed.to_s.gsub(/.adoc$|.ad$|.asciidoc$|.index$|.txt$/, '.html')
          options[:to_dir] = html_dir
          options[:to_file] = html_file_name
          options[:attributes] = @attributes_bk
          Asciidoctor.render_file(f, options)

          # end
        end

        #
        # Check if snippet parameter is defined
        # and remove the snippet tag from indexed files
        #
        if options[:snippet_content] == true
          files.each do |f|
            remove_tag_from_index_file(f)
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
      def self.table_of_content_to_asciidoc(toc_file, out_dir, project_name, image_path)

        Hyla.logger.info '>> Project Name : ' + project_name + ' <<'

        # Open file & parse it
        f = File.open(toc_file, 'r')

        # Expand File Path
        @out_dir = File.expand_path out_dir
        Hyla.logger.info '>> Output directory : ' + out_dir + ' <<'

        #
        # Create destination directory if it does not exist
        #
        unless Dir.exist? @out_dir
          FileUtils.mkdir_p @out_dir
        end

        # Copy YAML Config file
        FileUtils.cp_r [Configuration::templates, Configuration::YAML_CONFIG_FILE_NAME] * '/', @out_dir

        # Copy styles
        # FileUtils.cp_r Configuration::styles, @out_dir

        #
        # Move to the directory as we will
        # create content relative to this directory
        #
        Dir.chdir @out_dir
        @out_dir = Pathname.pwd

        # Create index file of all index files
        @project_index_file = self.create_index_file_withoutprefix(project_name, Configuration::LEVEL_1)


        # File iteration
        f.each do |line|

          #
          # Check level 1
          # Create a directory where its name corresponds to 'Title Level 1' &
          # where we have removed the leading '=' symbol and '.' and
          # replaced ' ' by '_'
          #
          if line[/^=\s/]

            #
            # Create the Directory name for the module and next the files
            # The special characters are removed from the string
            #
            dir_name = remove_special_chars(2, line)
            new_dir = [@out_dir, dir_name].join('/')
            FileUtils.rm_rf new_dir
            FileUtils.mkdir new_dir
            Hyla.logger.info '>> Directory created : ' + new_dir + ' <<'

            Dir.chdir(new_dir)

            # Add image, audio, video directory
            # self.create_asset_directory(['image', 'audio', 'video'])
            self.create_asset_directory(['image'])

            #
            # Create an index file
            # It is used to include files belonging to a module and will be used for SlideShow
            # The file created contains a title (= Dir Name) and header with attributes
            #
            @index_file = create_index_file_withoutprefix(dir_name, Configuration::LEVEL_1)

            #
            # Include index file created to parent index file
            # we don't prefix the AllSlides.txt file anymore
            #
            # BEFORE @project_index_file.puts Configuration::INCLUDE_PREFIX + dir_name + '/' + dir_name + Configuration::INDEX_SUFFIX + Configuration::INCLUDE_SUFFIX
            #
            @project_index_file.puts Configuration::INCLUDE_PREFIX + dir_name + '/' + Configuration::INDEX_FILE + Configuration::INCLUDE_SUFFIX
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
            # for the file 01, 00 within this module
            #
            @index = 0

            #
            # Add the cover.adoc file
            #
            @index += 1
            file_index = sprintf('%02d', @index)
            f_name = 'm' + @module_key + 'p' + file_index + '_cover' + Configuration::ADOC_EXT
            Hyla.logger.debug '>> Directory name : ' + dir_name.to_s.gsub('_', ' ')
            rep_txt = Configuration::COVER_TXT.gsub(/xxx\.png/, dir_name + '.png')
            Hyla.logger.debug "Replaced by : " + rep_txt
            cover_f = File.new(f_name, 'w')
            cover_f.puts rep_txt
            cover_f.close

            #
            # Use the filename & generate the cover image
            #
            out_dir = 'image'
            file_name = dir_name + '.html'
            image_name = dir_name + '.png'
            course_name = @project_name
            module_name= dir_name
            bg_image_path = image_path
            Hyla.logger.debug '>> Out Directory : ' + out_dir.to_s
            Hyla.logger.debug '>> Image name : ' + image_name.to_s
            Hyla.logger.debug '>> Course Name  : ' + course_name.to_s
            Hyla.logger.debug '>> Module Name  : ' + module_name.to_s
            Hyla.logger.debug '>> Bg Image  : ' + bg_image_path.to_s

            self.cover_img(out_dir, file_name, image_name, course_name, module_name, bg_image_path)

            #
            # Include cover file to index
            #
            @index_file.puts Configuration::INCLUDE_PREFIX + f_name + Configuration::INCLUDE_SUFFIX
            @index_file.puts "\n"

            #
            # Add the objectives.adoc file
            #
            @index += 1
            file_index = sprintf('%02d', @index)
            f_name = 'm' + @module_key + 'p' + file_index + '_objectives'

            rep_txt = Configuration::OBJECTIVES_TXT.gsub(/xxx\.mp3/, f_name + '.mp3')

            f_name = f_name + Configuration::ADOC_EXT

            objectives_f = File.new(f_name, 'w')
            objectives_f.puts Configuration::HEADER_TXT
            objectives_f.puts rep_txt
            objectives_f.close

            #
            # Include cover file to index
            #
            @index_file.puts Configuration::INCLUDE_PREFIX + f_name + Configuration::INCLUDE_SUFFIX
            @index_file.puts "\n"

            #
            # Add the labinstructions.adoc file
            #
            f_name = 'labinstructions' + Configuration::ADOC_EXT
            lab_f = File.new(f_name, 'w')
            lab_f.puts Configuration::HEADER_TXT
            lab_f.puts Configuration::LABS_TXT
            lab_f.close

            #
            # Add the assessment.txt file
            #
            f_name = 'assessment.txt'
            assessment_f = File.new(f_name, 'w')
            assessment_f.puts Configuration::ASSESSMENT_TXT
            assessment_f.close

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

              #
              # Add Footer_text to the file created
              #
              @previous_f.puts Configuration::FOOTER_TXT
              @previous_f.close
            end

            #
            # Replace special characters from the title before to generate the file name
            # Convert Uppercase to lowercase
            #
            f_name = remove_special_chars(3, line).downcase

            #
            # Create the prefix for the file
            # Convention : m letter followed by module number, letter p & a number 01, 02, ..., 0n, next the title & .adoc extension
            # Example : m01p01_mytitle.adoc, m01p02_anothertitle.adoc
            #
            @index += 1
            file_index = sprintf('%02d', @index)
            f_name = 'm' + @module_key + 'p' + file_index + '_' + f_name

            rep_txt = Configuration::AUDIO_TXT.gsub(/xxx\.mp3/, f_name + '.mp3')

            f_name = f_name + Configuration::ADOC_EXT

            #
            # Create File and add configuration HEADER_TXT
            #
            @new_f = File.new(f_name, 'w')
            @new_f.puts Configuration::HEADER_TXT
            @new_f.puts "\n"

            Hyla.logger.info '   # File created : ' + f_name.to_s

            @previous_f = @new_f

            # Include file to index
            @index_file.puts Configuration::INCLUDE_PREFIX + f_name + Configuration::INCLUDE_SUFFIX
            @index_file.puts "\n"
          end

          #
          # Add Content to file if it exists and line does not start with characters to be skipped
          #
          if !@new_f.nil? and !line.start_with?(Configuration::SKIP_CHARACTERS)
            #
            # Add audio text after the name of the title
            #
            #  ifdef::audioscript[]
            #    audio::audio/m01p03_why_use_messaging[]
            #  endif::[]
            #
            if line.start_with?('==')
              @new_f.puts line
              @new_f.puts "\n"
              @new_f.puts rep_txt
            else
              @new_f.puts line
            end
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

        @cover_path = cover_path
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
            next if file_name.downcase.include?('assessments')
            next if file_name.downcase.include?('labinstructions')
            next if file_name.downcase.include?('title')
            next if file_name.downcase.include?('cover')
            file = File.expand_path file
            list_of_files = list_of_files + " " + file
          end
        else
          #
          # If the file passed as parameter has extension name equal to txt, then we will extract the file names
          # whenever we have a include:: directive in the file
          #
          extension_name = File.extname file_name

          case extension_name
            when '.txt'
              file_to_processed = [File.expand_path(Dir.getwd), file_name] * '/'
              result = self.extract_file_names(file_to_processed, source)

              result.each do |file_path|
                if file_path.downcase.include?('title') || file_path.downcase.include?('cover')
                  @cover_path = file_path
                  next
                end
                list_of_files = list_of_files + " " + file_path
              end

            else
              list_of_files = [File.expand_path(source), file_name] * '/'
          end
        end

        wkhtml_cmd.concat " #{list_of_files} #{pdf_file}"
        wkhtml_cmd.concat " --margin-top '18mm' --header-html '#{header_html_path}'" if header_html_path
        wkhtml_cmd.concat " --margin-bottom '10mm'  --footer-center '#{footer_text}'" if footer_text
        wkhtml_cmd.concat " --cover '#@cover_path'" if @cover_path
        wkhtml_cmd.concat " --page-size #{size}"
        Hyla.logger.debug "c #{wkhtml_cmd}"

        Dir.chdir(source) do
          system "#{wkhtml_cmd}"
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
      # Remove space, dot, ampersand, hyphen, parenthesis characters from the String
      # at a position specified
      #
      def self.remove_special_chars(pos, text)
        return text[pos, text.length].strip.gsub(/\s/, '_')
                   .gsub('.', '')
                   .gsub('&', '')
                   .gsub('-', '')
                   .gsub(/\(|\)/, '')
                   .gsub('__', '_')
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
      # TODO : Not longer used -> can be removed
      #
      def self.create_index_file_withprefix(file_name, level)
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
      # Create ascidoc index file
      # containing references to asciidoc files part of a module
      #
      def self.create_index_file_withoutprefix(file_name, level)
        index_file = File.new(Configuration::INDEX_FILE, 'w')

        index_file.puts Configuration::HEADER_INDEX
        index_file.puts "\n"
        # TODO - until now we cannot use level 0 for parent/children files
        # even if doctype: book
        # This is why the level for each index file title is '=='

        rep_txt = Configuration::INDEX.gsub(/xxx/, file_name)
        index_file.puts rep_txt
        index_file.puts "\n"

#
        # index_file.puts "\n"

        index_file
      end

      #
      # Modify the content of an index file if
      # it contains include::file with extension .ad, .adoc or .asciidoc
      # and add the tag snippet ([] --> [tag=snippet])
      #
      def self.add_tag_to_index_file(index_file)
        if File.basename(index_file) == "AllSlides.txt" then
          content = ""
          File.readlines(index_file).each do |line|
            if line =~ /^include::.*\[\]$/
              replace = line.gsub(/\[/, '[tag=' + Configuration::SNIPPET_TAG)
              content = content.to_s + replace
            else
              content = content.to_s + line
            end
          end
          replace_content(index_file, content)
        end
      end

      #
      # Remove snippet tag from index file
      #
      def self.remove_tag_from_index_file(index_file)
        if File.basename(index_file) == "AllSlides.txt" then
          content = ""
          File.readlines(index_file).each do |line|
            if line =~ /^include::.*\[tag\=.*\]$/
              replace = line.gsub('[tag=' + Configuration::SNIPPET_TAG, '[')
              content = content.to_s + replace
            else
              content = content.to_s + line
            end
          end
          replace_content(index_file, content)
        end
      end

      #
      # Replace content of a File
      #
      def self.replace_content(f, content)
        File.open(f, "w") { |out| out << content } if !content.empty?
      end


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

      #
      # Extract files names from a file containing include:: directive
      #
      def self.extract_file_names(file_name, destination)

        result = []
        f = File.open(file_name, 'r')
        matches = f.grep(Configuration::IncludeDirectiveRx)

        if matches

          matches.each do |record|
            # Extract string after include::
            matchdata = record.match(/^include::(.+)/)

            if matchdata

              data = matchdata[1]
              # Remove []
              name = data.to_s.gsub(/[\[\]]/, '').strip

              # Rename file to .html
              name = name.gsub(/ad$/, 'html')
              file_name = [destination, name] * '/'
              file_path = File.expand_path file_name
              result << file_path
            end
          end
        end
        f.close
        return result
      end

    end # class
  end # module Commands
end # module Hyla
