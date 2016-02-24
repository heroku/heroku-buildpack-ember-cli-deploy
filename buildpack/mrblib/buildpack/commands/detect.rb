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
      package_json = "#{@build_dir}/package.json"

      exit 1 if !File.exist?(package_json)

      json         = JSON.parse(File.read(package_json))
      dependencies = json["devDependencies"]

      if dependencies["ember-cli-deploy"]
        puts "ember-cli-deploy"
      else
        exit 1
      end
    end
  end
end
