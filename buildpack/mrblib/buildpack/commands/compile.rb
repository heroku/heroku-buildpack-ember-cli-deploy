module Buildpack
  module Shell; end

  module Commands
    class Compile
      include Buildpack::Shell

      STATIC_JSON  = "static.json"
      PACKAGE_JSON = "package.json"
      BOWER_DIR    = "bower_components"

      def self.detect(options)
        options["compile"]
      end

      def initialize(output_io, error_io, build_dir, cache_dir, env_dir)
        @output_io = output_io
        @error_io  = error_io
        @build_dir = build_dir
        @cache_dir = cache_dir
        @env_dir   = env_dir
        @cache     = Cache.new(@build_dir, @cache_dir)
      end

      def run
        Dir.chdir(@build_dir) do
          unless command_success?("bower -v 2> /dev/null")
            @output_io.topic "Installing bower"
            pipe("npm install -g bower")
          end

          @output_io.topic "Restoring bower cache" if @cache.load(BOWER_DIR, ".")
          @output_io.topic "Installing bower dependencies"
          pipe("bower --allow-root install")
          @output_io.topic "Caching bower cache"
          @cache.store(BOWER_DIR)

          unless command_success?("ember version 2> /dev/null")
            @output_io.topic "Installing ember-cli"
            pipe("npm install -g ember-cli")
          end

          @output_io.topic "Building ember assets"
          ember_cli_deploy =
            if dependencies["ember-cli-deploy"]
              pipe("ember deploy production")
              true
            else
              pipe("ember build --environment production")
              false
            end

          exit 1 unless DefaultStaticConfig.new(@output_io, @error_io).write(STATIC_JSON, ember_cli_deploy)
        end
      end

      private
      def dependencies
        unless @modules
          json     = JSON.parse(File.read(PACKAGE_JSON))
          @modules = (json["devDependencies"] || {}).merge(json["dependencies"] || {})
        end

        @modules
      end

    end
  end
end
