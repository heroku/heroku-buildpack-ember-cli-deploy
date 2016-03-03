module Buildpack
  module Commands; end
  module Shell; end

  class CLI
    include Commands
    include Shell

    USAGE = <<USAGE
Ember CLI Deploy Buildpack

Usage:
  buildpack detect <build-dir>
  buildpack compile <build-dir> <cache-dir> <env-dir>
  buildpack release <build-dir>
  buildpack (-v | --version)
  buildpack (-h | --help)

Options:
  -h --h        Show this screen.
  -v --version  Show version.
USAGE

    def initialize(argv, output_io = $stdout, error_io = $stderr)
      @options   = Docopt.parse(USAGE, argv)
      @output_io = output_io
      @error_io  = error_io

      @output_io.instance_eval do
        def topic(message)
          puts "-----> #{message}"
        end
      end
    end

    def run
      if Version.detect(@options)
        Version.new(@output_io).run
      elsif Detect.detect(@options)
        Detect.new(@options["<build-dir>"], @output_io, @error_io).run
      elsif Compile.detect(@options)
        Compile.new(@output_io, @error_io, @options["<build-dir>"], @options["<cache-dir>"], @options["<env-dir>"]).run
      elsif Release.detect(@options)
        Release.new(@output_io, @error_io, @options["<build-dir>"]).run
      else
        Help.new(@output_io).run
      end
    end
  end
end
