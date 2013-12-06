require 'Hyla/WebSocket'

module Hyla
  module Commands
    class Reload

      attr_reader :web_sockets, :thread, :options

      def initialize()
        # puts "We have been called"
      end

      def start(args, options)

        @options = {
            host:           '0.0.0.0',
            port:           '35729',
            apply_css_live: true,
            override_url:   false,
            grace_period:   0
        }.merge(options)

        @web_sockets = []

        @Websocket ||= Hyla::WebSocket

        @thread = thread.new _start_reactor

      end

      def stop
        # thread.kill
      end

      def reload_browser(paths = [])
        Hyla.logger.info "Reloading browser: #{paths.join(' ')}"
        paths.each do |path|
          data = _data(path)
          Hyla.logger.debug(data)
          web_sockets.each { |ws| ws.send(MultiJson.encode(data)) }
        end
      end

      private

      def _data(path)
        data = {
            command: 'reload',
            path:    "#{Dir.pwd}/#{path}",
            liveCSS: options[:apply_css_live]
        }
        if options[:override_url] && File.exist?(path)
          data[:overrideURL] = '/' + path
        end
        data
      end

      def _start_reactor
        EventMachine.epoll
        EventMachine.run do
          EventMachine.start_server(options[:host], options[:port], @Websocket, {}) do |ws|
            ws.onopen    { _connect(ws) }
            ws.onclose   { _disconnect(ws) }
            ws.onmessage { |msg| _print_message(msg) }
          end
          Hyla.logger.info "LiveReload is waiting for a browser to connect."
        end
      end

      def _connect(ws)
        Hyla.logger.info "Browser connected."
        ws.send MultiJson.encode(
                    command:    'hello',
                    protocols:  ['http://livereload.com/protocols/official-7'],
                    serverName: 'guard-livereload'
                )
        @web_sockets << ws
      rescue
        Hyla.logger.error $!
        Hyla.logger.error $!.backtrace
      end

      def _disconnect(ws)
        Hyla.logger.info "Browser disconnected."
        @web_sockets.delete(ws)
      end

      def _print_message(message)
        message = MultiJson.decode(message)
        Hyla.logger.info "Browser URL: #{message['url']}" if message['command'] == 'url'
      end

    end # end class
  end # end module Commands
end # end module Hyla