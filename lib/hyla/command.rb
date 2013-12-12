module Hyla
  class Command
    program :int_block do
      # kill threads etc
      # make sure to exit or abort, otherwise your program keeps running
      Hyla::logger.warn "CTRL-C / Shutdown command received"
      exit 1
    end

  end
end