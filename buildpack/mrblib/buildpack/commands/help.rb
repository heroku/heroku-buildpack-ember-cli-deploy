module Buildpack::Commands
  class Help
    def initialize(output_io)
      @output_io = output_io
    end

    def run
      @output_io.puts Buildpack::CLI::USAGE
    end
  end
end
