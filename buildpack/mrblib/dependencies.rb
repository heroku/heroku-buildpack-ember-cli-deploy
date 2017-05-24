module Buildpack
  class Dependencies
    CONFIG_FILE = "package.json"

    def initialize(build_dir)
      file = "#{build_dir}/#{CONFIG_FILE}"

      if File.exist?(file)
        @modules          = JSON.parse(File.read(file))
        @all_dependencies = (@modules["devDependencies"] || {}).merge(@modules["dependencies"] || {})
      else
        @modules          = nil
        @all_dependencies = nil
      end
    end

    def valid?
      !@modules.nil?
    end

    def [](dependency)
      @all_dependencies[dependency]
    end
  end
end
