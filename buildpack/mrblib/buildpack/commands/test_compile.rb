module Buildpack
  module Shell; end

  module Commands
    class TestCompile
      include Buildpack::Shell

      def self.detect(options)
        options["test-compile"]
      end

      def initialize(output_io, error_io, build_dir, cache_dir, env_dir)
        @output_io = output_io
        @error_io  = error_io
        @build_dir = build_dir.chomp("/")
        @cache_dir = cache_dir.chomp("/")
        @env       = Env.create(env_dir)
        # remove PATH, since sprettur sets PATH and overrides any exports from the node buildpack
        @env.delete("PATH")
        @cache     = Cache.new(@build_dir, @cache_dir)
      end

      def run
        @output_io.topic "Detecting testem browsers"
        json = `node vendor/testem_broswers.js #{@build_dir}`
        if !json.chomp.empty?
          browsers = JSON.parse(json)["browsers"]
          if browsers.include?("PhantomJS")
            @output_io.topic "Installing PhantomJS"
            pipe_exit_on_error("npm install -g phantomjs-prebuilt", @output_io, @error_io, @env)
          end

          if browsers.include?("Chrome")
            @output_io.topic "Install headless Chrome"
          end
        end
      end
    end
  end
end
