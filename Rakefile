require 'tmpdir'
require 'fileutils'

desc "Build and stage buildpack in a tmpdir"
task :stage do
  @dir = Dir.mktmpdir
  sh "git clone . #{@dir}"

  Dir.chdir(@dir) do
    Dir.chdir("buildpack") do
      sh "docker-compose run compile"
    end

    FileUtils.mkdir_p("vendor")
    FileUtils.cp("buildpack/mruby/build/x86_64-pc-linux-gnu/bin/buildpack", "vendor")
    sh "sudo rm -rf buildpack"
    FileUtils.rm("Rakefile")
  end

  puts @dir
end

desc "Publish buildpack to https://buildkits.herokuapp.com"
task :publish, [:name] => :stage do |t, args|
  Dir.chdir(@dir) do
    sh "heroku buildkits:publish #{args[:name]}"
  end
end
