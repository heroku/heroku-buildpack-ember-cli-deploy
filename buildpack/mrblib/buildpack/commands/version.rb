module Buildpack::Commands
  class Version
    def self.detect(options)
      options["--version"] || options["-v"]
    end

    def initialize(output_io)
      @output_io = output_io
    end

    def run
      @output_io.puts "v#{Buildpack::VERSION}"
    end
  end
end
