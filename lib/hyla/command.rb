module Hyla
  class Command

    def self.globs(source, destination)
      Dir.chdir(source) do
        dirs = Dir['*'].select { |x| File.directory?(x) }
        dirs -= [destination, File.expand_path(destination), File.basename(destination)]
        dirs = dirs.map { |x| "#{x}/**/*" }
        dirs += ['*']
      end
    end

    program :int_block do
      # kill threads etc
      # make sure to exit or abort, otherwise your program keeps running
      Hyla::logger.warn "CTRL-C / Shutdown command received"
      exit 1
    end

  end
end