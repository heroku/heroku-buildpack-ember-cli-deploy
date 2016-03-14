module Buildpack
  class Env
    def self.create(env_dir)
      env = {}

      Dir.foreach(env_dir) do |file|
        fullpath = "#{env_dir}/#{file}"
        env[file] = File.read(fullpath).chomp if File.exist?(fullpath) && !Dir.exist?(fullpath)
      end

      env
    end
  end
end
