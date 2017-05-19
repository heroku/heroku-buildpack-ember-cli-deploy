module Buildpack
  module Shell; end

  module Commands
    class Test
      include Buildpack::Shell

      def self.detect(options)
        options["test"]
      end

      def initialize(output_io, error_io, build_dir, env_dir)
        @output_io = output_io
        @error_io  = error_io
        @build_dir = build_dir.chomp("/")
        @env       = Env.create(env_dir)
        # remove PATH, since sprettur sets PATH and overrides any exports from the node buildpack
        @env.delete("PATH")
      end

      def run
        Dir.chdir(@build_dir) do
          pipe_exit_on_error("npm test", @output_io, nil, @env)
        end
      end
    end
  end
end
