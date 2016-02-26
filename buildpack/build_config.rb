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
  conf.linker.flags << "-static-libstdc++"
  conf.linker.flags << "-static-libgcc"

  gem_config(conf)
end

MRuby::Build.new('x86_64-pc-linux-gnu') do |conf|
  toolchain :gcc

  conf.linker.flags << "-static-libstdc++"
  conf.linker.flags << "-static-libgcc"

  gem_config(conf)
end
