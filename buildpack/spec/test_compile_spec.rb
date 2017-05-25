require 'tmpdir'
require 'json'

RSpec.describe "test_compile" do
  fit "should detect PhantomJS" do
    Dir.mktmpdir("test_compile") do |tmpdir|
      cache_dir = "#{tmpdir}/cache"
      env_dir   = "#{tmpdir}/env"
      work_dir = "#{tmpdir}/work"
      FileUtils.mkdir_p(cache_dir)
      FileUtils.mkdir_p(env_dir)
      FileUtils.cp_r(fixtures("super-rentals"), work_dir)

      Dir.chdir("..") do
        output, _, status = run_bin("test-compile", work_dir, cache_dir, env_dir)
        puts output
        puts _
        expect(status).to be_success
      end
    end
  end
end
