module Hyla
  module Commands
    class Reload < Command

      attr_reader :web_sockets, :thread, :options

      DEFAULT_OPTIONS = {
          host: '0.0.0.0',
          port: '35729',
          apply_css_live: true,
          override_url: false,
          grace_period: 0
      }

      @@web_sockets = []

      def initialize()
      end

      def process(options)
        @options = DEFAULT_OPTIONS.clone.merge(options)
        @Websocket ||= Hyla::WebSocket
        _start
      end

      def reload_browser(paths = [])
        Hyla.logger2.info "Reloading browser: #{paths.join(' ')}"
        paths.each do |path|
          Hyla.logger2.info(path)
          data = _data(path)
          Hyla.logger2.info(">> Data received : #{data}")
          @@web_sockets.each { |ws| ws.send(MultiJson.encode(data)) }
        end
      end

      def reload_browser2(paths = [])
        Hyla.logger2.info "Reloading browser: #{paths.join(' ')}"
        paths.each do |path|
          Hyla.logger2.info(path)
          data = 'hyla/development/'
          Hyla.logger2.info(">> Data received : #{data}")
          @@web_sockets.each { |ws| ws.send(MultiJson.encode(data)) }
        end
      end

      private

      def _start
        _start_reactor
      end

      def _stop
        thread.kill
      end

      def _data(path)

        # TODO Improve that
        # path:    "#{Dir.pwd}/#{path}",

        data = {
            command: 'reload',
            path: "#{path}",
            liveCSS: @options[:apply_css_live]
        }
        if options[:override_url] && File.exist?(path)
          data[:overrideURL] = '/' + path
        end
        data
      end

      def _start_reactor
        Hyla.logger2.info "LiveReload is waiting for a browser to connect."
        EventMachine.epoll
        EventMachine.run do
          EventMachine.start_server(@options[:host], @options[:port], @Websocket, {}) do |ws|
            ws.onopen { _connect(ws) }
            ws.onclose { _disconnect(ws) }
            ws.onmessage { |msg| _print_message(msg) }
          end
        end
      end

      def _connect(ws)
        Hyla.logger2.info "Browser connected."
        ws.send MultiJson.encode(
                    command: 'hello',
                    protocols: ['http://livereload.com/protocols/official-7'],
                    serverName: 'guard-livereload'
                )
        @@web_sockets << ws
      rescue
        Hyla.logger2.error $!
        Hyla.logger2.error $!.backtrace
      end

      def _disconnect(ws)
        Hyla.logger2.info "Browser disconnected."
        @@web_sockets.delete(ws)
      end

      def _print_message(message)
        message = MultiJson.decode(message)
        Hyla.logger2.info "Browser URL: #{message['url']}" if message['command'] == 'url'
      end

    end # class
  end # module Commands
end # module Hyla