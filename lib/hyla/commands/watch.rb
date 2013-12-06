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
          :watch_ext => %w(ad adoc asc asciidoc),
          :run_on_start => false,
          :backend => 'html5',
          :eruby => 'erb',
          :doctype => 'article',
          :compact => false,
          :attributes => {},
          :always_build_all => false,
          :to_dir => '.'
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

        puts "Listen called !"

        # opts = DEFAULT_OPTIONS.clone

        listener = Listen.to('../data/generated') do |modified, added, removed|

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

          listener.start # not blocking
          sleep

          trap("INT") do
            listener.stop
            puts "     Halting auto-regeneration."
            exit 0
          end

        end # listen

      end

    end # Class Watch
  end # Module Commands
end # Module Hyla
