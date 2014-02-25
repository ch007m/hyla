module Hyla
  module Commands
    class Serve < Command

      def self.process(args, options)
        include WEBrick

        my_opts = {}

        destination = options[:destination]  if self.check_mandatory_option?('-d / --destination', options[:destination])

        my_opts[:Port] = options[:port]
        my_opts[:BindAddress] = options[:host]
        my_opts[:baseurl] = options[:baseurl]
        my_opts[:MimeTypes] = self.mime_types
        my_opts[:DoNotReverseLookupmy_opts] = true
        my_opts[:StartCallback] = start_callback(options[:detach])
        my_opts[:AccessLog] = []
        my_opts[:Logger] = Log::new([], Log::WARN)

        # recreate NondisclosureName under utf-8 circumstance
        fh_option = WEBrick::Config::FileHandler
        fh_option[:NondisclosureName] = ['.ht*','~*']
        # Option added to allow to navigate into the directories
        fh_option[:FancyIndexing] = true

        #s = HTTPServer.new(webrick_options(my_opts))
        s = HTTPServer.new(my_opts)

        s.mount(my_opts[:baseurl],HTTPServlet::FileHandler, destination, fh_option)

        Hyla.logger.info "Server address:", "http://#{s.config[:BindAddress]}:#{s.config[:Port]}"

        if options[:detach] # detach the server
          pid = Process.fork { s.start }
          Process.detach(pid)
          Hyla.logger.info "Server detached with pid '#{pid}'.", "Run `kill -9 #{pid}' to stop the server."
        else # create a new server thread, then join it with current terminal
          t = Thread.new { s.start }
          trap("INT") { s.shutdown }
          t.join()
        end
      end


      def self.start_callback(detached)
        unless detached
          Proc.new { Hyla.logger.info "Server running...", "press ctrl-c to stop." }
        end
      end

      def self.mime_types
        mime_types_file = File.expand_path('../../../data/mime.types', File.dirname(__FILE__))
        WEBrick::HTTPUtils::load_mime_types(mime_types_file)
      end

    end # class
  end # module Commands
end # module Hyla