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
        @env_dir   = env_dir
        @env       = Env.create(env_dir)
        # remove PATH, since sprettur sets PATH and overrides any exports from the node buildpack
        @env.delete("PATH")
        @cache     = Cache.new(@build_dir, @cache_dir)
      end

      def run
        Dir.chdir(@build_dir) do
          Bower.new(@output_io, @error_io, @cache).install
        end

        @output_io.topic "Detecting testem browsers"

        content = nil
        config = ["testem.json", ".testem.json", "testem.yml", ".testem.yml"].detect {|file| File.exist?("#{@build_dir}/#{file}") }
        if config
          content = File.read("#{@build_dir}/#{config}")
        else
          content, status = system("node vendor/testem_browsers.js #{@build_dir} 2>&1")
          if !status.success?
            @output.puts "No testem config found."
            exit 1
          end
        end

        if !content.chomp.empty?
          browsers =
            (
              if config && config.split(".").last == "yml"
                YAML.load(content)
              else
                JSON.parse(content)
              end
            )["launch_in_ci"]

          if browsers.nil? || browsers.empty?
            @output_io.print <<MSG
No browsers detected.
Add 'PhantomJS' or 'Chrome' in your testem config
MSG
            exit 1
          end

          dependencies = Dependencies.new(@build_dir)

          if browsers.include?("PhantomJS")
            if dependencies["phantomjs-prebuilt"]
              @output_io.topic "Skipping PhantomJS, already installed."
            else
              @output_io.topic "Installing PhantomJS"
              phantomjs_output_log = "phantomjs_output.log"
              status = pipe("npm install -g phantomjs-prebuilt 2>&1 1>#{phantomjs_output_log}", @output_io, @env)
              @error_io.puts File.read(phantomjs_output_log) if !status.success?
            end
          end

          if browsers.include?("Chrome")
            @output_io.topic "Installing headless Chrome"
            GitBuildpackRunner.new(@output_io, @error_io, "heroku/heroku-buildpack-google-chrome").compile(@build_dir, @cache_dir, @env_dir)
          end
        end
      end
    end
  end
end
