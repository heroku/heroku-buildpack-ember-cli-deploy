module Buildpack
  module Shell; end

  module Commands
    class Compile
      include Buildpack::Shell

      STATIC_JSON                  = "static.json"
      PACKAGE_JSON                 = "package.json"
      DEFAULT_EMBER_CLI_DEPLOY_DIR = "tmp/deploy-dist"
      DEFAULT_EMBER_CLI_DIR        = "dist"

      def self.detect(options)
        options["compile"]
      end

      def initialize(output_io, error_io, build_dir, cache_dir, env_dir)
        @output_io = output_io
        @error_io  = error_io
        @build_dir = build_dir
        @cache_dir = cache_dir
        @env_dir   = env_dir
      end

      def run
        Dir.chdir(@build_dir) do
          unless command_success?("bower -v 2> /dev/null")
            @output_io.topic "Installing bower"
            pipe("npm install -g bower")
          end

          @output_io.topic "Installing bower dependencies"
          pipe("bower --allow-root install")

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

          contents = default_static_json(ember_cli_deploy)
          if contents
            @output_io.topic "Writing static.json"
            File.open(STATIC_JSON, 'w') do |file|
              file.puts contents
            end
          end
        end
      end

      private
      def default_static_json(ember_cli_deploy = false)
        # TODO catch if JSON isn't valid
        json = File.exist?(STATIC_JSON) ? JSON.parse(File.read(STATIC_JSON)) : {}

        if json.include?('root') && json.include?('routes')
          nil
        else
          json['root'] ||= ember_cli_deploy ? DEFAULT_EMBER_CLI_DEPLOY_DIR : DEFAULT_EMBER_CLI_DIR
          json['routes'] ||= {
            '/**' => 'index.html'
          }
          JSON.generate(json, {
            :pretty_print => true,
            :indent       => 2
          })
        end
      end

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
