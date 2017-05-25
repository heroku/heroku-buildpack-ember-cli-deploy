module Buildpack::Commands
  class Detect
    def self.detect(options)
      options["detect"]
    end

    def initialize(build_dir, output_io, error_io)
      @build_dir = build_dir
      @output_io = output_io
      @error_io  = error_io
    end

    def run
      dependencies = Dependencies.new(@build_dir)

      exit 1 if !dependencies.valid?

      if dependencies["ember-cli-deploy"]
        puts "ember-cli-deploy"
      elsif dependencies["ember-cli"]
        puts "ember-cli"
      else
        exit 1
      end
    end
  end
end
