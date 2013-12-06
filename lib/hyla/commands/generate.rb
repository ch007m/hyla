module Hyla
  module Commands
    class Generate

      attr_reader :artefact

      def initialize()
        @config = Hyla::Configuration.new
      end

      #
      # Method parsing TOC File to generate directories and files
      # Each Level 1 entry will become a directory
      # and each Level 2 a file created under the directory
      #
      # @param [File Containing the Table of Content] toc_file
      # @param [Directory where asciidoc files will be generated] out_dir
      # @param [Project name used to create parent of index files] project_name
      def table_of_content_to_asiidoc(toc_file, out_dir, project_name)

        Hyla.logger.info '>> Project Name : ' + project_name + ' <<'

        # Open file & parse it
        f = File.open(toc_file, 'r')

        # Re Create Directory of generated content
        FileUtils.rm_rf out_dir if Dir.exist? out_dir
        FileUtils.makedirs(out_dir)

        # Move to 'generated' directory as we will
        # create content relative to this directory
        Dir.chdir out_dir
        out_dir = Pathname.pwd

        # Create index file of all index files
        @project_index_file = create_index_file(project_name, @config.LEVEL_1)


        # File iteration
        f.each do |line|

          # Check level 1
          # Create a directory where its name corresponds to 'Title Level 1' &
          # where we have removed the leading '=' symbol and '.' and
          # replaced ' ' by '_'
          if line[/^=\s/]

            # Create File
            dir_name = remove_special_chars(2, line)
            new_dir = [out_dir, dir_name].join('/')
            Hyla.logger.info '>> Directory created : ' + new_dir + ' <<'
            FileUtils.mkdir_p new_dir
            Dir.chdir(new_dir)

            # Add images directory
            Dir.mkdir('images')

            # Create an index file
            # It is used to include files belonging to a module and will be used for SlideShows
            # The file created contains a title (= Dir Name) and header with attributes
            @index_file = create_index_file(dir_name, @config.LEVEL_2)

            # Include index file created to parent index file
            @project_index_file.puts @config.INCLUDE_PREFIX + dir_name + '/' + dir_name + @config.INDEX_SUFFIX + @config.INCLUDE_SUFFIX

            # Move to next line record
            next
          end

          # Check Level 2
          # Create a file for each Title Level 2 where name corresponds to title (without '==' symbol) &
          # where we have removed the leading '==' symbol  and '.' and replace ' ' by '_'
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
            @new_f.puts @config.HEADER

            @previous_f = @new_f

            # Include file to index
            @index_file.puts @config.INCLUDE_PREFIX + f_name + @config.INCLUDE_SUFFIX
          end

          # Add Content to file if it exists and line does not start with characters to be skipped
          if !@new_f.nil? and !line.start_with?(@config.SKIP_CHARACTERS)
              @new_f.puts line
          end

        end

      end

      # method parse_file(f)

      #
      # Remove space, dot from a String
      #
      def remove_special_chars(pos, text)
        return text[pos, text.length].strip.gsub(/\s/, '_').gsub('.', '')
      end

      # Add '/' at the end of the target path
      # if the target path provided doesn't contain it
      def check_slash_end(out_dir)
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
      def create_index_file(file_name, level)
        n_file_name = file_name + @config.INDEX_SUFFIX
        index_file = File.new(n_file_name, 'w')
        index_file.puts level + file_name
        index_file.puts @config.HEADER_INDEX

        index_file
      end

    end # Class Generate
  end # module Commands
end # module Hyla