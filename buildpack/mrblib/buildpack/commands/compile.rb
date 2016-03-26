module Buildpack
  module Shell; end

  module Commands
    class Compile
      include Buildpack::Shell

      EmberBuildTuple = Struct.new(:deploy, :command, :output_dir)
      CacheLoadTuple  = Struct.new(:build_dest, :cache_src)

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
        @env       = Env.create(env_dir)
        @cache     = Cache.new(@build_dir, @cache_dir)
      end

      def run
        Dir.chdir(@build_dir) do
          unless command_success?("bower -v 2> /dev/null")
            @output_io.topic "Installing bower"
            pipe_exit_on_error("npm install -g bower", @output_io, @error_io, @env)
          end

          @output_io.topic "Restoring bower cache" if @cache.load(BOWER_DIR, ".")
          @output_io.topic "Installing bower dependencies"
          pipe_exit_on_error("bower --allow-root install", @output_io, @error_io, @env)
          @output_io.topic "Caching bower cache"
          @cache.store(BOWER_DIR)

          unless command_success?("ember version 2> /dev/null")
            @output_io.topic "Installing ember-cli"
            pipe_exit_on_error("npm install -g ember-cli", @output_io, @error_io, @env)
          end

          tuple =
            if dependencies["ember-cli-deploy"]
              EmberBuildTuple.new(true, "ember deploy production", StaticConfig::DEFAULT_EMBER_CLI_DEPLOY_DIR)
            else
              EmberBuildTuple.new(false, "ember build --environment production", StaticConfig::DEFAULT_EMBER_CLI_DIR)
            end

          @output_io.topic "Building ember assets"
          pipe_exit_on_error(tuple.command, @output_io, @error_io, @env)
          cache_load_tuple = cache_load_dirs(tuple.output_dir)
          @output_io.topic "Loading old ember assets" if @cache.load(cache_load_tuple.cache_src, cache_load_tuple.build_dest, false)
          @output_io.topic "Caching ember assets"
          @cache.store(tuple.output_dir)

          if dependencies["ember-cli-fastboot"]
            @output_io.topic "ember fastboot detected"
            fastboot_node_modules_cache = "dist/node_modules"
            cache_load_tuple            = cache_load_dirs(fastboot_node_modules_cache)
            @output_io.topic "Restoring fastboot dependencies" if @cache.load(cache_load_tuple.cache_src, cache_load_tuple.build_dest)
            @output_io.topic "Installing fastboot dependencies"
            pipe_exit_on_error("cd #{tuple.output_dir} && npm install", @output_io, @error_io, @env)
            @output_io.topic "Caching fastboot dependencies"
            @cache.store(fastboot_node_modules_cache, cache_load_tuple.build_dest)

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
      def dependencies
        unless @modules
          json     = JSON.parse(File.read(PACKAGE_JSON))
          @modules = (json["devDependencies"] || {}).merge(json["dependencies"] || {})
        end

        @modules
      end

      def cache_load_dirs(local_dir)
        output_parts = local_dir.split("/")
        build_dest   = nil
        cache_src    = nil

        if output_parts.size > 1
          build_dest = output_parts.dup.tap {|o| o.pop }.join("/")
          cache_src  = local_dir
        else
          build_dest = "."
          cache_src = output_parts.last
        end

        CacheLoadTuple.new(build_dest, cache_src)
      end

    end
  end
end
