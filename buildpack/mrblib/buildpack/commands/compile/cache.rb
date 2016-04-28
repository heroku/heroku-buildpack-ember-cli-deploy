class Buildpack::Commands::Compile::Cache
  BUILDPACK_CACHE_DIR = "ember-cli-deploy"

  def initialize(build_dir, cache_dir)
    @build_dir = build_dir
    @cache_dir = "#{cache_dir}/#{BUILDPACK_CACHE_DIR}"
  end

  def load(dir, path = ".", override = true)
    src     = "#{@cache_dir}/#{dir}"
    options = override ? "" : "-n"

    if File.exist?(src)
      FileUtilsSimple.cp_r(src, "#{@build_dir}/#{path}", options)
      true
    else
      false
    end
  end

  def store(dir, destination = ".")
    FileUtilsSimple.mkdir_p("#{@cache_dir}/#{destination}")
    FileUtilsSimple.cp_r("#{@build_dir}/#{dir}", "#{@cache_dir}/#{destination}/")
  end

  def read(path)
    cache_path = "#{@cache_dir}/#{path}"
    File.read(cache_path) if File.exist?(cache_path)
  end

  def exist?(path)
    File.exist?("#{@cache_dir}/#{path}")
  end

  def rm(path)
    FileUtilsSimple.rm("#{@cache_dir}/#{path}")
  end
end
