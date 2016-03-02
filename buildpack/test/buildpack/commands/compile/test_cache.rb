class TestCache < MTest::Unit::TestCase
  Cache = Buildpack::Commands::Compile::Cache

  def setup
    @build_dir           = generate_dir("build")
    @cache_dir           = generate_dir("cache")
    @buildpack_cache_dir = "#{@cache_dir}/#{Cache::BUILDPACK_CACHE_DIR}"
    @cache               = Cache.new(@build_dir, @cache_dir)
  end

  def teardown
    FileUtilsSimple.rm_rf(@cache_dir)
    FileUtilsSimple.rm_rf(@build_dir)
  end

  def test_load
    buildpack_cache_dir = "#{@cache_dir}/#{Cache::BUILDPACK_CACHE_DIR}"

    FileUtilsSimple.mkdir_p(buildpack_cache_dir)
    File.open("#{buildpack_cache_dir}/foo.txt", "w") do |file|
      file.puts "foo"
    end

    cached_dir = "#{buildpack_cache_dir}/bar"
    FileUtilsSimple.mkdir_p(cached_dir)
    File.open("#{cached_dir}/baz.txt", "w") do |file|
      file.puts "baz"
    end

    assert_true @cache.load("foo.txt", ".")
    assert_equal "foo", File.read("#{@build_dir}/foo.txt").chomp

    FileUtilsSimple.mkdir_p("#{@build_dir}/slam")
    assert_true @cache.load("bar", "slam")
    assert_equal "baz", File.read("#{@build_dir}/slam/bar/baz.txt").chomp
  end

  def test_load_empty
    assert_false @cache.load("foo", ".")
  end

  def test_load_override
    asset_dir = "#{@build_dir}/dist"
    FileUtilsSimple.mkdir_p(asset_dir)
    File.open("#{asset_dir}/foo.txt", "w") do |file|
      file.print "foo"
    end
    File.open("#{asset_dir}/bar.txt", "w") do |file|
      file.print "bar"
    end
    @cache.store("dist")

    FileUtilsSimple.rm_rf(asset_dir)
    FileUtilsSimple.mkdir_p(asset_dir)
    File.open("#{asset_dir}/bar.txt", "w") do |file|
      file.print "baz"
    end
    @cache.load("dist", ".", false)

    assert_equal "foo", File.read("#{asset_dir}/foo.txt")
    assert_equal "baz", File.read("#{asset_dir}/bar.txt")
  end

  def test_store
    cacheable_dir = "#{@build_dir}/foo"
    FileUtilsSimple.mkdir_p(cacheable_dir)
    File.open("#{cacheable_dir}/foo.txt", "w") do |file|
      file.print "foo"
    end

    @cache.store("foo")
    assert_equal "foo", File.read("#{@buildpack_cache_dir}/foo/foo.txt")
  end

  private
  def generate_dir(name)
    tmpfile = Tempfile.new(name)
    path    = tmpfile.path
    tmpfile.unlink
    FileUtilsSimple.mkdir_p(path)

    path
  end
end

MTest::Unit.new.run
