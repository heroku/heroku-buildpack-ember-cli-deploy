def gem_config(conf)
  #conf.gembox 'default'

  # be sure to include this gem (the cli app)
  conf.gem File.expand_path(File.dirname(__FILE__))
  conf.gem github: 'hone/mruby-io',      branch: 'popen_status'
  conf.gem github: 'hone/mruby-process', branch: 'header'
  # needed by mruby-iijson
  conf.gem core: 'mruby-sprintf'
  conf.enable_cxx_abi
end

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  gem_config(conf)
  # needed by mruby-tempfile
  conf.gem core: 'mruby-time'
  conf.gem mgem: 'mruby-simple-random'
end

MRuby::Build.new('x86_64-pc-linux-gnu') do |conf|
  toolchain :gcc

  ["-static-libgcc", "-static-libstdc++"].each do |flag|
    conf.linker.flags << flag
  end

  gem_config(conf)
end
