module Buildpack
  module Shell; end

  module Commands
    class Compile
      include Buildpack::Shell

      STATIC_JSON = "static.json"
      DEFAULT_EMBER_CLI_DEPLOY_DIR = "tmp/deploy-dist"

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
          pipe("ember deploy production")

          contents = static_json_contents
          if contents
            @output_io.topic "Writing static.json"
            File.open(STATIC_JSON, 'w') do |file|
              file.puts contents
            end
          end
        end
      end

      private
      def static_json_contents
        # TODO catch if JSON isn't valid
        json = File.exist?(STATIC_JSON) ? JSON.parse(File.read(STATIC_JSON)) : {}
        if json['root']
          nil
        else
          json['root'] = DEFAULT_EMBER_CLI_DEPLOY_DIR
          JSON.generate(json, {
            :pretty_print => true,
            :indent       => 2
          })
        end
      end
    end
  end
end
