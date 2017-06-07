module Buildpack
  module Shell; end

  module Commands
    class Compile
      include Buildpack::Shell

      EmberBuildTuple = Struct.new(:deploy, :command, :output_dir)
      CacheTuple      = Struct.new(:source, :destination)

      STATIC_JSON  = "static.json"
      PACKAGE_JSON = "package.json"

      def self.detect(options)
        options["compile"]
      end

      def initialize(output_io, error_io, build_dir, cache_dir, env_dir)
        @output_io = output_io
        @error_io  = error_io
        @build_dir = build_dir.chomp("/")
        @cache_dir = cache_dir.chomp("/")
        @env       = Env.create(env_dir)
        @cache     = Cache.new(@build_dir, @cache_dir)
      end

      def run
        Dir.chdir(@build_dir) do
          Bower.new(@output_io, @error_io, @cache).install

          unless command_success?("ember version 2> /dev/null")
            @output_io.topic "Installing ember-cli"
            pipe_exit_on_error("npm install -g ember-cli", @output_io, @error_io, @env)
          end

          dependencies = Dependencies.new(@build_dir)
          ember_env = Shellwords.escape(@env.fetch("EMBER_ENV", StaticConfig::DEFAULT_EMBER_ENV))

          tuple =
            if dependencies["ember-cli-deploy"]
              ember_cli_deploy_target = Shellwords.escape(@env.fetch("EMBER_CLI_DEPLOY_TARGET", ember_env))
              EmberBuildTuple.new(true, "ember deploy #{ember_cli_deploy_target}", StaticConfig::DEFAULT_EMBER_CLI_DEPLOY_DIR)
            else
              EmberBuildTuple.new(false, "ember build --environment #{ember_env}", StaticConfig::DEFAULT_EMBER_CLI_DEPLOY_DIR)
            end

          @output_io.topic "Building ember assets"
          pipe_exit_on_error("#{tuple.command} 2>&1", @output_io, @error_io, @env)
          cache_tuple = cache_dirs(tuple.output_dir)
          @output_io.topic "Loading old ember assets" if @cache.load(cache_tuple.source, cache_tuple.destination, false)
          @output_io.topic "Caching ember assets"
          @cache.store(tuple.output_dir, ".")

          if dependencies["ember-cli-fastboot"]
            @output_io.topic "ember fastboot detected"
            cache_tuple = CacheTuple.new("fastboot", tuple.output_dir)
            @output_io.topic "Restoring fastboot dependencies" if @cache.load("#{cache_tuple.source}/node_modules", cache_tuple.destination)
            @output_io.topic "Installing fastboot dependencies"
            pipe_exit_on_error("cd #{tuple.output_dir} && npm install 2>&1", @output_io, @error_io, @env)
            @output_io.topic "Caching fastboot dependencies"
            @cache.store("#{cache_tuple.destination}/node_modules", cache_tuple.source)

            unless command_success?("node_modules/.bin/ember-fastboot 2> /dev/null")
              @output_io.topic "ember-fastboot command not detected, installing fastboot-cli"
              pipe_exit_on_error("npm install fastboot-cli", @output_io, @error_io, @env)
            end
            release_yml = {
              "default_process_types" => {
                "web" => "ember-fastboot #{tuple.output_dir} --serve-assets-from #{tuple.output_dir} --port $PORT"
              }
            }
            FileUtilsSimple.mkdir_p("#{@build_dir}/tmp")
            File.open("#{@build_dir}/#{Release::FILE_PATH}", "w") do |file|
              file.puts YAML.dump(release_yml)
            end
          else
            exit 1 unless DefaultStaticConfig.new(@output_io, @error_io).write(STATIC_JSON, tuple.deploy)
          end
        end
      end

      private
      def cache_dirs(local_dir)
        output_parts = local_dir.split("/")
        destination  = nil
        source       = nil

        if output_parts.size > 1
          destination = output_parts.dup.tap {|o| o.pop }.join("/")
          source      = output_parts.dup.tap {|o| o.shift }.join("/")
        else
          destination = "."
          source = output_parts.last
        end

        CacheTuple.new(source, destination)
      end
    end
  end
end
