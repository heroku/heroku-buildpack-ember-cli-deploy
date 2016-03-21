class TestEnv < MTest::Unit::TestCase
  Env = Buildpack::Env

  def test_create
    env = {
      "FOO" => "foo",
      "BAR" => "bar",
      "BAZ" => "baz"
    }

    mktmpdir("env") do |dir|
      env.each do |key, value|
        File.open("#{dir}/#{key}", "w") {|f| f.puts value }
      end

      created_env = Env.create(dir)
      
      assert_equal env, created_env
    end
  end

  def test_create_no_env_dir
    assert_equal Hash.new, Env.create("/foo/bar")
  end

  private
  def mktmpdir(name)
    tmpfile = Tempfile.new(name)
    path    = tmpfile.path
    tmpfile.unlink
    FileUtilsSimple.mkdir_p(path)

    yield path
  ensure
    FileUtilsSimple.rm_rf(path)
  end
end

MTest::Unit.new.run
