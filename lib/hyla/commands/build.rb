module Hyla
  module Commands
    class Build < Command

      def process(options)
        training = Hyla::Training.new(options)
        build(training, options)
      end

      #
      #
      #
      def build(training, options)
        source = options['source']
        destination = options['destination']
        Hyla.logger.info "Source: ", source
        Hyla.logger.info "Destination: ", destination
        print Hyla.logger.formatted_topic "Generating..."
        self.process_training(training)
        puts "done."
      end

      # Static: Run Training#process and catch errors
      #
      # training - the Hyla::Training object
      #
      # Returns nothing
      def self.process_training(training)
        training.process
      rescue Hyla::FatalException => e
        puts
        Hyla.logger.error "ERROR:", "YOUR TRAINING COULD NOT BE BUILT:"
        Hyla.logger.error "", "------------------------------------"
        Hyla.logger.error "", e.message
        exit(1)
      end

    end # class
  end # module Commands
end # module Hyla