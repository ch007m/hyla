module Hyla
  class Command
    program :int_block do
      # kill threads etc
      # make sure to exit or abort, otherwise your program keeps running
      Hyla::logger2.warn "CTRL-C / Shutdown command received"
      exit 1
    end

    #
    # Check mandatory options
    #
    def self.check_mandatory_option?(key, value)
      if value.nil? or value.empty?
        Hyla.logger2.warn "Mandatory option missing: #{key}"
        exit(1)
      else
        true
      end
    end

  end
end