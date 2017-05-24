module Buildpack
  module Shell; end

  class GitBuildpackRunner
    include Shell

    def initialize(output_io, error_io, name)
      @output_io = output_io
      @error_io  = error_io
      @name      = name
    end

    def compile(build_dir, cache_dir, env_dir, exports = [])
      fetch_buildpack do
        output, status = system("#{source_exports(exports)} bin/compile #{build_dir} #{cache_dir} #{env_dir} 2>&1")
        on_error(status, "Failed trying to compile #{@name}:\n#{output}")
      end
    end

    private
    def on_error(status, message)
      if !status.success?
        @error_io.topic message
        exit status.exitstatus
      end
    end

    def source_exports(exports)
      if exports.any?
        exports.map {|export| ". #{export}" }.join(" && ") + " &&"
      else
        ""
      end
    end

    def fetch_buildpack
      @output_io.topic "Fetching buildpack #{@name}"

      if block_given?
        mktmpdir("buildpack") do |dir|
          Dir.chdir(dir) do
            pipe("git clone --depth=1 https://github.com/#{@name}")
            Dir.chdir(@name.split("/").last)

            yield
          end
        end
      else
        pipe("git clone --depth=1 https://github.com/#{@name}")
      end
    end
  end
end
