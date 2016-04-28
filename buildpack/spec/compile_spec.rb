require 'tmpdir'
require 'json'
RSpec.describe "compile" do
  Tuple = Struct.new(:app, :output_path)

  it "should compile an ember-cli-deploy app" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        assert_compile(dir, "ember-cli-deploy")
      end
    end
  end

  it "should compile an ember-cli app" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        assert_compile(dir, "ember-cli")
      end
    end
  end

  it "should compile a fastboot build app" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        assert_compile(dir, "ember-cli-deploy-fastboot-build")
      end
    end
  end

  def assert_compile(tmpdir, type)
    tuple =
      case type
      when "ember-cli"
        Tuple.new("github-issues-demo", "dist")
      when "ember-cli-deploy"
        Tuple.new("github-issues-demo-deploy", "tmp/deploy-dist")
      when "ember-cli-deploy-fastboot-build"
        Tuple.new("ember-api-docs", "tmp/deploy-dist")
      end

    cache_dir = "#{tmpdir}/cache"
    env_dir   = "#{tmpdir}/env"
    Dir.mkdir(cache_dir)
    Dir.mkdir(env_dir)
    File.open("#{env_dir}/FASTLY_CDN_URL", "w") do |file|
      "limitless-caverns-12345.global.ssl.fastly.net"
    end
    work_dir = "#{tmpdir}/#{tuple.app}"
    cache_output_path = tuple.output_path.split("/").last
    FileUtils.cp_r(fixtures(tuple.app), tmpdir)

    output, _, status = run_bin('compile', work_dir, cache_dir, env_dir)
    expect(status).to be_success
    expect(File.exist?("#{work_dir}/#{tuple.output_path}")).to eq(true)
    expect(output).not_to include("Restoring bower cache")
    expect(output).not_to include("Loading old ember assets")
    expect(Dir.exist?("#{cache_dir}/ember-cli-deploy/bower_components")).to be true
    expect(Dir.exist?("#{cache_dir}/ember-cli-deploy/#{cache_output_path}")).to be true

    if type.include?("fastboot")
      expect(output).not_to include("Restoring fastboot dependencies")
      expect(Dir.exist?("#{cache_dir}/ember-cli-deploy/fastboot/node_modules")).to be true
    else
      expect(File.exist?("#{work_dir}/static.json")).to be true
      json = JSON.parse(File.read("#{work_dir}/static.json"))
      expect(json["root"]).to eq(tuple.output_path)
      expect(json["routes"]).to be_truthy
    end

    FileUtils.rm_rf(work_dir)
    FileUtils.cp_r(fixtures(tuple.app), tmpdir)
    robots_txt = <<ROBOTS
User-agent: *
Disallow: /tmp/
ROBOTS
    File.open("#{work_dir}/public/robots.txt", "w") do |file|
      file.print robots_txt
    end
    output, _, status = run_bin('compile', work_dir, cache_dir, env_dir)
    expect(status).to be_success
    expect(File.read("#{work_dir}/#{tuple.output_path}/robots.txt")).to eq(robots_txt)
    expect(output).to include("Restoring bower cache")
    expect(output).to include("Loading old ember assets")
    if type.include?("fastboot")
      expect(output).to include("Restoring fastboot dependencies")
    end
  end
end
