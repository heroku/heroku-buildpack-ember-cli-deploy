class TestStaticConfig < MTest::Unit::TestCase
  StaticConfig = Buildpack::StaticConfig

  def test_to_json_deploy
    json = <<JSON
{
  "root": "tmp/deploy-dist",
  "routes": {
    "/**": "index.html"
  }
}
JSON

    assert_equal json.chomp, StaticConfig.new("{}", true).to_json
  end

  def test_to_json_non_deploy
    json = <<JSON
{
  "root": "dist",
  "routes": {
    "/**": "index.html"
  }
}
JSON

    assert_equal json.chomp, StaticConfig.new("{}", false).to_json
  end

  def test_to_json_has_root
    input = <<JSON
{
  "root": "public"
}
JSON
    result = <<JSON
{
  "root": "public",
  "routes": {
    "/**": "index.html"
  }
}
JSON

    assert_equal result.chomp, StaticConfig.new(input).to_json
  end

  def test_to_json_has_routes
    input = <<JSON
{
  "routes": {
    "/admin/**": "/admin/index.html"
  }
}
JSON

    actual = JSON.parse(StaticConfig.new(input).to_json)
    routes = { "/admin/**" => "/admin/index.html" }

    assert_equal "dist", actual["root"]
    assert_equal routes, actual["routes"]
  end

  def test_write_has_root
    json = <<JSON
{
  "root": "dist"
}
JSON

    assert StaticConfig.new(json).write?
  end

  def test_write_has_routes
    json = <<JSON
{
  "routes": {
    "/**": "index.html"
  }
}
JSON

    assert StaticConfig.new(json).write?
  end

  def test_write_empty
    assert StaticConfig.new("{}").write?
  end

  def test_write_all_keys
    json = <<JSON
{
  "root": "tmp/deploy-dist",
  "routes": {
    "/**": "index.html"
  }
}
JSON

    assert !StaticConfig.new(json).write?
  end
end

MTest::Unit.new.run
