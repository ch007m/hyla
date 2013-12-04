module Guard
    class Watch < Guard

      DEFAULT_OPTIONS = {
          :watch_dir => '.',
          :watch_ext => %w(ad adoc asc asciidoc),
          :run_on_start => false,
          :backend => 'html5',
          :eruby => 'erb',
          :doctype => 'article',
          :compact => false,
          :attributes => {},
          :always_build_all => false
      }

      def initialize(watchers = [], options = {})
        init(watchers = [], options = {})
        super watchers, merged_opts
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

      def start
        UI.info 'Guard::AsciiDoc has started watching your files'
        require @options[:eruby]
        run_all if @options[:run_on_start]
      end

      def run_all
        # TODO is this too eager?
        # TODO does this honor the input path?
        run Watcher.match_files(self, Dir['*.{ad,asc,adoc,asciidoc}'])
      end

      def run_on_changes(paths)
        opts = @options

        if opts[:always_build_all]
          run_all
        else
          run paths
        end
      end

      def run(paths)
        paths.each do |file_path|
          UI.info "Change detected: #{file_path}"
          opts = @options
          if opts.has_key? :to_dir
            opts[:to_dir] = File.join(Dir.pwd, opts[:to_dir])
          else
            opts[:in_place] = true
          end
          opts[:safe] = Asciidoctor::SafeMode::SAFE
          # TODO if first file fails, still process remaining
          Asciidoctor.render_file(file_path, opts)
        end
        true
      end
    end # Class Watch
end
