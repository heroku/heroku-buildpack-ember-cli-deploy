class TestDefaultStaticConfig < MTest::Unit::TestCase
  DefaultStaticConfig = Buildpack::Commands::Compile::DefaultStaticConfig

  DEFAULT_JSON = <<JSON
{
  "root": "tmp/dist",
  "routes": {
    "/**": "index.html"
  }
}
JSON

  def test_invalid_json
    tempfile = Tempfile.new('static')
    stdout   = StringIO.new
    stderr   = StringIO.new
    config   = DefaultStaticConfig.new(stdout, stderr)

    tempfile.write("|")
    tempfile.close

    assert !config.write(tempfile.path, false)
  ensure
    tempfile.unlink
  end

  def test_valid_json
    tempfile = Tempfile.new('static')
    stdout   = StringIO.new
    stdout.instance_eval do
      def topic(message)
        puts "-----> #{message}"
      end
    end
    stderr   = StringIO.new
    config   = DefaultStaticConfig.new(stdout, stderr)

    tempfile.write("{}")
    tempfile.close

    assert config.write(tempfile.path, false)
  ensure
    tempfile.unlink
  end
end

MTest::Unit.new.run
