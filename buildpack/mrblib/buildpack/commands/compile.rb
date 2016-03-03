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

          tuple =
            if dependencies["ember-cli-deploy"]
              EmberBuildTuple.new(true, "ember deploy production", StaticConfig::DEFAULT_EMBER_CLI_DEPLOY_DIR)
            else
              EmberBuildTuple.new(false, "ember build --environment production", StaticConfig::DEFAULT_EMBER_CLI_DIR)
            end

          @output_io.topic "Building ember assets"
          pipe(tuple.command)
          cache_load_tuple = cache_load_dirs(tuple.output_dir)
          @output_io.topic "Loading old ember assets" if @cache.load(cache_load_tuple.cache_src, cache_load_tuple.build_dest, false)
          @output_io.topic "Caching ember assets"
          @cache.store(tuple.output_dir)

          if dependencies["ember-cli-fastboot"]
            @output_io.topic "ember fastboot detected"
            fastboot_dist =
              if dependencies["ember-cli-deploy-fastboot-build"]
                "tmp/fastboot-dist"
              else
                @output_io.topic "Building ember fastboot assets"
                pipe("ember fastboot:build --environment production")
                "fastboot-dist"
              end

            fastboot_node_modules_cache = "#{fastboot_dist}/node_modules"
            cache_load_tuple = cache_load_dirs(fastboot_node_modules_cache)
            @output_io.topic "Restoring fastboot dependencies" if @cache.load(cache_load_tuple.cache_src, cache_load_tuple.build_dest)
            @output_io.topic "Installing fastboot dependencies"
            pipe("cd #{fastboot_dist} && npm install")
            @cache.store("#{fastboot_dist}/node_modules", "fastboot-dist")

            release_yml = {
              "default_process_types" => {
                "web" => "ember fastboot --environment production --build false --port $PORT --output-path #{fastboot_dist} --assets-path #{tuple.output_dir} --serve-assets"
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
          cache_src  = output_parts.dup.tap {|o| o.shift }.join("/")
        else
          build_dest = "."
          cache_src = output_parts.last
        end

        CacheLoadTuple.new(build_dest, cache_src)
      end

    end
  end
end
