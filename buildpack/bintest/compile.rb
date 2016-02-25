require 'tmpdir'
require 'json'

assert('compile') do
  app = "github-issues-demo"

  Dir.mktmpdir do |dir|
    Dir.chdir(dir) do
      FileUtils.cp_r(Support.fixtures(app), dir)
      work_dir = "#{dir}/#{app}"
      output, status = Support.run_bin('compile', work_dir, '/tmp', '/tmp')
      puts output

      assert_true status.success?, "buildpack compile did not exit properly"
      assert_true File.exist?("#{work_dir}/tmp/deploy-dist"), "ember dist directory does not exist"
      assert_true File.exist?("#{work_dir}/static.json"), "did not detect static.json"

      json = JSON.parse(File.read("#{work_dir}/static.json"))
      assert_equal "tmp/deploy-dist", ["root"]
      assert_true json["routes"]
    end
  end
end
