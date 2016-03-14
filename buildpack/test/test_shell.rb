class TestShell < MTest::Unit::TestCase
  def setup
    @foo = Object.new
    @foo.instance_eval do
      extend Buildpack::Shell
    end
  end

  def test_system
    output, status = @foo.system(%q{echo "hello"})

    assert_true status.success?
    assert_equal "hello", output.chomp
  end

  def test_system_env
    mktmpdir("shell") do |dir|
      File.open("#{dir}/test.sh", "w") do |file|
        file.puts <<FILE
#!/bin/sh
echo $FOO
FILE
      end

      output, status = @foo.system("sh #{dir}/test.sh", {"FOO" => "foo"})

      assert_true status.success?
      assert_equal "foo", output.chomp
    end
  end

  def test_pipe
    output = StringIO.new
    status = @foo.pipe(%q{echo "hello"}, output)

    assert_true status.success?
    assert_equal "hello", output.string.chomp
  end

  def test_pipe_env
    mktmpdir("shell") do |dir|
      File.open("#{dir}/test.sh", "w") do |file|
        file.puts <<FILE
#!/bin/sh
echo $FOO
FILE
      end

      output = StringIO.new
      status = @foo.pipe("sh #{dir}/test.sh", output, {"FOO" => "foo"})

      assert_true status.success?
      assert_equal "foo", output.string.chomp
    end
  end

  def test_command_success
    assert_true @foo.command_success?(%q{echo "hello"})
    assert_false @foo.command_success?("foo 2>1")
  end

  def test_command_success_env
    mktmpdir("shell") do |dir|
      File.open("#{dir}/pass.sh", "w") do |file|
        file.puts <<FILE
#!/bin/sh
echo $FOO
FILE
      end
      File.open("#{dir}/fail.sh", "w") do |file|
        file.puts <<FILE
#!/bin/sh
echo $FOO
exit 1
FILE
      end
      env = {"FOO" => "foo"}

      assert_true @foo.command_success?("sh #{dir}/pass.sh", env)
      assert_false @foo.command_success?("sh #{dir}/fail.sh", env) 
    end
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
