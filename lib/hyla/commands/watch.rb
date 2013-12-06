#require 'celluloid/autostart'

module Hyla
  module Commands
    class Watch

      #include Celluloid

      def initialize
        #@cellulloid = Celluloid::Celluloid.new
        #@cellulloid.boot
        #Celluloid.logger.level = Logger::INFO
      end

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

      def listen(args, options = {})

=begin
        # opts = DEFAULT_OPTIONS.clone

        puts "Listen called !"

        # Create a callback
        callback = Proc.new do |modified, added, removed|
          puts "Listen started !"
          puts "modified absolute path: #{modified}"
          puts "added absolute path: #{added}"
          puts "removed absolute path: #{removed}"

          puts "File changed: #{modified.first}"

          to_dir = File.dirname(modified.first)
          to_file = Pathname.new(modified.first).basename.to_s.gsub('adoc', 'html')
          # to_file = to_file.gsub('.adoc','.html')
          puts "Output Directory: #{to_dir}"
          puts "To File : #{to_file}"

          if !modified.nil? or !added.nil?
            Asciidoctor.render_file(modified.first, :backend => 'html5', :to_dir => to_dir, :to_file => to_file, :safe => :unsafe)
            #Hyla::Commands::Watch.reload_browser([to_dir])
            #f = File.new(to_dir, 'w')
            #f.puts html
            #f.close
          end
        end
        # force_polling: true
        # &callback
        listener = Listen.to('../data/generated', debug: true, wait_for_delay: 2)
        listener.start # not blocking
        puts "This is a test"
        puts listener.listen?

        trap("INT") do
          listener.stop
          puts "     Halting watching."
          exit 0
        end
=end

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
          Hyla.logger.info ">> Directory of the file to be generated : #{calc_dir}"
          FileUtils.makedirs calc_dir

          @opts[:to_dir] = calc_dir

          Hyla.logger.info ">> Asciidoctor options : #{@opts}"

          Asciidoctor.render_file(f, @opts)
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
