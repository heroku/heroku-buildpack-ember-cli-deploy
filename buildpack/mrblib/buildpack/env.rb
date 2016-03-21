module Buildpack
  class Env
    def self.create(env_dir)
      env = {}
      return env unless Dir.exist?(env_dir)

      Dir.foreach(env_dir) do |file|
        fullpath = "#{env_dir}/#{file}"
        env[file] = File.read(fullpath).chomp if File.exist?(fullpath) && !Dir.exist?(fullpath)
      end

      env
    end
  end
end
