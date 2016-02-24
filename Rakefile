require 'tmpdir'
require 'fileutils'

task :stage do
  dir = Dir.mktmpdir
  sh "git clone . #{dir}"

  Dir.chdir(dir) do
    Dir.chdir("buildpack") do
      sh "docker-compose run compile"
    end

    FileUtils.mkdir_p("vendor")
    FileUtils.cp("buildpack/mruby/build/x86_64-pc-linux-gnu/bin/buildpack", "vendor")
    sh "sudo rm -rf buildpack"
    FileUtils.rm("Rakefile")
  end

  puts dir
end
