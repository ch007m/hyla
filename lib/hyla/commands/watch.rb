module Hyla
  module Commands
    class Watch < Command

      WS_OPTIONS = {
          :base_url => '/modules'
      }

      def initialize
      end

      def self.start_livereload
        @reload = Hyla::Commands::Reload.new
        @t = Thread.new { @reload.process(WS_OPTIONS) }
      end

      def self.process(args, options = {})

        # Start LiveReload
        self.start_livereload

        @opts = options
        @opts_bk = @opts

        if options.has_key? :destination
          @opts[:to_dir] = File.expand_path options[:destination]
        end

        if options.has_key? :source
          @opts[:watch_dir] = File.expand_path options[:source]
        end

        #
        # Guard Listen Callback
        # Detect files modified, deleted or added
        #
        callback = Proc.new do |modified, added, removed|
          Hyla.logger.info "modified absolute path: #{modified}"
          Hyla.logger.info "added absolute path: #{added}"
          Hyla.logger.info "removed absolute path: #{removed}"

          if !modified.nil? or !added.nil?
            modified.each do |modify|
              Hyla.logger.info "File modified : #{modify}"
              call_asciidoctor(modify)
            end

            added.each do |add|
              Hyla.logger.info "File added : #{add}"
              call_asciidoctor(add)
            end

          end
        end # callback

        Hyla.logger.info ">> ... Starting\n"
        Hyla.logger.info ">> Hyla has started to watch files in this dir : #{@opts[:watch_dir]}"
        Hyla.logger.info ">> Results of rendering will be available here : #{@opts[:to_dir]}"

        # TODO : Investigate issue with Thread pool is not running (Celluloid::Error)
        # when using a more recent version of guard listen
        listener = Listen.to!(@opts[:watch_dir], &callback)

        trap(:INT) {
          Hyla.logger.info "Interrupt intercepted"
          Thread.kill(@t)
        }
      end

      # listen

      def self.call_asciidoctor(f)
        dir_file = File.dirname(f)
        file_to_process = Pathname.new(f).basename
        @ext_name = File.extname(file_to_process)

        if [".adoc",".ad",".asciidoc",".txt",".index"].include? @ext_name

          Hyla.logger.info ">> Directory containing file(s) to be processed : #{dir_file}"
          Hyla.logger.info ">> File to be processed : #{file_to_process}"
          Hyla.logger.info ">> Extension of the file : #{@ext_name}"

          # Generate File name
          # Rename xxx.adoc, xxx.asciidoc, xxx.ad, xxx.index to xxx.html
          to_file = file_to_process.to_s.gsub(/.adoc$|.ad$|.asciidoc$|.index$/, '.html')
          @opts[:to_file] = to_file

          # Use destination from original config
          @opts[:to_dir] = @opts_bk[:destination]

          # Calculate Asciidoc to_dir relative to the dir of the file to be processed
          # and create dir in watched dir
          rel_dir = substract_watch_dir(dir_file, @opts[:watch_dir])
          if !rel_dir.empty?
            calc_dir = File.expand_path @opts[:to_dir] + rel_dir
            FileUtils.makedirs calc_dir
          else
            calc_dir = File.expand_path @opts[:to_dir]
          end

          @opts[:to_dir] = calc_dir

          Hyla.logger.info ">> Directory of the file to be generated : #{calc_dir}"
          Hyla.logger.debug ">> Asciidoctor options : #{@opts}"

          # Render Asciidoc document
          Asciidoctor.render_file(f, @opts)

          # Refresh browser connected using LiveReload
          path = []
          path.push(calc_dir)
          @reload.reload_browser(path)
        end
      end

      def self.substract_watch_dir(file_dir, watched_dir)
        s = file_dir.sub(watched_dir, '')
        Hyla.logger.info ">> Relative directory : #{s}"
        s
      end

    end # class
  end # module Commands
end # module Hyla
