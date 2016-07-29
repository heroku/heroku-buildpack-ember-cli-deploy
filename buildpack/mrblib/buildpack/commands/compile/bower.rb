class Buildpack::Commands::Compile::Bower
  include Buildpack::Shell

  BOWER_JSON   = "bower.json"
  BOWER_DIR    = "bower_components"

  def initialize(output_io, error_io, cache)
    @output_io = output_io
    @error_io  = error_io
    @cache     = cache
  end

  def install
    unless command_success?("bower -v 2> /dev/null")
      @output_io.topic "Installing bower"
      pipe_exit_on_error("npm install -g bower", @output_io, @error_io, @env)
    end

    if @cache.exist?(BOWER_DIR) && bower_cache_stale?
      @cache.rm(BOWER_DIR)
      @output_io.topic("bower.json changes detected, clearing cache")
    elsif @cache.exist?(BOWER_DIR)
      @output_io.topic "Restoring bower cache"
    end

    @output_io.topic "Restoring bower cache" if @cache.load(BOWER_DIR, ".") && !bower_cache_stale?
    @output_io.topic "Installing bower dependencies"
    pipe_exit_on_error("bower --allow-root install 2>&1", @output_io, @error_io, @env)
    @output_io.topic "Caching bower cache"
    @cache.store(BOWER_DIR)

    FileUtilsSimple.mkdir_p("checksums")
    File.open("checksums/#{BOWER_JSON}", "w") {|file| file.puts MD5::md5_hex(File.read(BOWER_JSON)) }
    @cache.store("checksums/#{BOWER_JSON}", "checksums")
  end

  def bower_cache_stale?
    current_md5 = MD5::md5_hex(File.read(BOWER_JSON))
    old_md5     = @cache.read("checksums/#{BOWER_JSON}").chomp if @cache.exist?("checksums/#{BOWER_JSON}")

    old_md5 != current_md5
  end
end
