require 'tmpdir'
require 'json'

Tuple = Struct.new(:app, :output_path)

def assert_compile(tmpdir, type)
  tuple =
    case type
    when "ember-cli"
      Tuple.new("github-issues-demo", "dist")
    when "ember-cli-deploy"
      Tuple.new("github-issues-demo-deploy", "tmp/deploy-dist")
    when "ember-fastboot-deploy"
      Tuple.new("ember-api-docs", "tmp/deploy-dist")
    end

  cache_dir = "#{tmpdir}/cache"
  Dir.mkdir(cache_dir)
  work_dir = "#{tmpdir}/#{tuple.app}"
  cache_output_path = tuple.output_path.split("/").last
  FileUtils.cp_r(Support.fixtures(tuple.app), tmpdir)

  output, _, status = Support.run_bin('compile', work_dir, cache_dir, '/tmp')

  assert_true status.success?, "buildpack compile did not exit properly"
  assert_true File.exist?("#{work_dir}/#{tuple.output_path}"), "ember dist directory does not exist"
  assert_false output.include?("Restoring bower cache"), "Should not be restoring cache"
  assert_false output.include?("Loading old ember assets"), "Should not be loading old ember assets"
  assert_true Dir.exist?("#{cache_dir}/ember-cli-deploy/bower_components"), "bower_components/ directory does not exist"
  assert_true Dir.exist?("#{cache_dir}/ember-cli-deploy/#{cache_output_path}"), "ember dist directory does not exist"

  if type.include?("fastboot")
    assert_false output.include?("Restoring fastboot dependencies"), "Should not be loading old ember assets"
    assert_true Dir.exist?("#{cache_dir}/ember-cli-deploy/fastboot-dist/node_modules"), "fastboot node modules cache does not exist"
  else
    assert_true File.exist?("#{work_dir}/static.json"), "did not detect static.json"
    json = JSON.parse(File.read("#{work_dir}/static.json"))
    assert_equal tuple.output_path, json["root"]
    assert_true json["routes"]
  end

  FileUtils.rm_rf(tuple.app)
  FileUtils.cp_r(Support.fixtures(tuple.app), tmpdir)
  robots_txt = <<ROBOTS
User-agent: *
Disallow: /tmp/
ROBOTS
  File.open("#{work_dir}/public/robots.txt", "w") do |file|
    file.print robots_txt
  end
  output, _, status = Support.run_bin('compile', work_dir, cache_dir, '/tmp')
  puts output
  assert_true status.success?, "buildpack compile did not exit properly"
  assert_equal robots_txt, File.read("#{work_dir}/#{tuple.output_path}/robots.txt")
  assert_true output.include?("Restoring bower cache"), "bower cache was not restored"
  assert_true output.include?("Loading old ember assets"), "old ember assets were not loaded"
  if type.include?("fastboot")
    assert_true output.include?("Restoring fastboot dependencies")#, "Should not be loading old ember assets"
  end
end

assert('compile ember-cli-deploy') do
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      assert_compile(dir, "ember-cli-deploy")
    end
  end
end

assert('compile ember-cli') do
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      assert_compile(dir, "ember-cli")
    end
  end
end

assert('compile fastboot') do
  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      assert_compile(dir, "ember-fastboot-deploy")
    end
  end
end
