module Hyla
  module Commands
    class Watch < Command

      DEFAULT_OPTIONS = {
          :watch_dir => '.',
          :watch_ext => %w(ad adoc asc asciidoc txt index),
          :run_on_start => false,
          :backend => 'html5',
          :eruby => 'erb',
          :doctype => 'article',
          :compact => false,
          :attributes => {},
          :always_build_all => false,
          :to_dir => '.',
          :to_file => '',
          :safe => :unsafe,
          :header_footer => true
      }

      WS_OPTIONS = {
          :host => '0.0.0.0'
      }

      def initialize
        # We will start the WS Server used by LiveReload
        @reload = Hyla::Commands::Reload.new
      end

      def init(watchers = [], options = {})
        watchers = [] if !watchers
        merged_opts = DEFAULT_OPTIONS.clone

        if options.has_key? :watch_dir
          merged_opts[:watch_dir] = options.delete :watch_dir
          # set output to input if input is specified, but not output
          unless options.has_key? :to_dir
            merged_opts[:to_dir] = merged_opts[:watch_dir]
          end
        end

        merged_opts.merge! options

        # house cleaning
        merged_opts[:watch_dir] = '.' if merged_opts[:watch_dir].to_s.empty?
        merged_opts.delete(:to_dir) if (merged_opts[:to_dir] == '.' || merged_opts[:to_dir].to_s.empty?)

        if merged_opts[:watch_dir] == '.'
          input_re = ''
        else
          merged_opts[:watch_dir].chomp!('/') while merged_opts[:watch_dir].end_with?('/')
          merged_opts[:watch_dir] << '/'
          input_re = Regexp.escape merged_opts[:watch_dir]
        end

        watch_re = %r{^#{input_re}.+\.(?:#{merged_opts[:watch_ext] * '|'})$}
        watchers << ::Guard::Watcher.new(watch_re)
        merged_opts[:attributes] = {} unless merged_opts[:attributes]
        # set a flag to indicate running environment
        merged_opts[:attributes]['guard'] = ''
      end

      def start_ws_server()
        @thread = Thread.new { @reload.start(WS_OPTIONS) }
        Hyla.logger.debug "WS Server Started"
      end

      def self.process(args, options = {})

        # Start WS Server used by Livereload
        # start_ws_server()

        @opts = DEFAULT_OPTIONS.clone
        @received_opts = options

        if options.has_key? :out_dir
          @opts[:to_dir] = options[:out_dir]
        end

        if options.has_key? :watch_dir
          @opts[:watch_dir] = options[:watch_dir]
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

        Hyla.logger.info ">> Hyla has started to watch files in this output dir :  #{@opts[:watch_dir]}"
        Hyla.logger.info ">> Results of Asciidoctor generation will be available here : #{@opts[:to_dir]}"
        listener = Listen.to!('../data/generated', &callback)

        trap(:INT){
          Hyla.logger.info "Interrupt intercepted"
          Thread.kill
        }


      end # listen

      def call_asciidoctor(f)
        dir_file = File.dirname(f)
        file_to_process = Pathname.new(f).basename
        @ext_name = File.extname(file_to_process)
        Hyla.logger.info ">> Directory of the file to be processed : #{dir_file}"
        Hyla.logger.info ">> File to be processed : #{file_to_process}"
        Hyla.logger.info ">> Extension of the file : #{@ext_name}"

        if @ext_name != '.html'
          to_file = file_to_process.to_s.gsub('adoc', 'html')
          @opts[:to_file] = to_file

          # TODO Check why asciidoctor populates new attributes and remove to_dir
          # TODO when it is called a second time
          # Workaround - reset list, add again :out_dir
          @opts[:attributes] = {}
          @opts[:to_dir] = @received_opts[:out_dir]

          # Calculate Asciidoc to_dir relative to the dir of the file to be processed
          # and create dir in watched dir
          rel_dir = substract_watch_dir(dir_file, @opts[:watch_dir])
          calc_dir = @opts[:to_dir] + rel_dir
          FileUtils.makedirs calc_dir

          @opts[:to_dir] = calc_dir

          Hyla.logger.info ">> Directory of the file to be generated : #{calc_dir}"
          Hyla.logger.debug ">> Asciidoctor options : #{@opts}"

          # Render Asciidoc document
          Asciidoctor.render_file(f, @opts)

          # Refresh browser
          path = []
          path.push(calc_dir)
          @reload.reload_browser(path)
        end
      end

      def substract_watch_dir(file_dir, watched_dir)
        s = file_dir.sub(watched_dir,'')
        Hyla.logger.info ">> Relative directory : #{s}"
        s
      end

    end # Class Watch
  end # Module Commands
end # Module Hyla
