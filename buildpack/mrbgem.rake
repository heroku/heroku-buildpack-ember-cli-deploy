MRuby::Gem::Specification.new('buildpack') do |spec|
  spec.license = 'MIT'
  spec.author  = 'MRuby Developer'
  spec.summary = 'buildpack'
  spec.bins    = ['buildpack']

  spec.add_dependency 'mruby-exit',             core: 'mruby-exit'
  spec.add_dependency 'mruby-struct',           core: 'mruby-struct'
  spec.add_dependency 'mruby-dir',              mgem: 'mruby-dir'
  spec.add_dependency 'mruby-iijson',           mgem: 'mruby-iijson'
  spec.add_dependency 'mruby-set',              mgem: 'mruby-set'
  spec.add_dependency 'mruby-docopt',           github: 'hone/mruby-docopt'
  spec.add_dependency 'mruby-fileutils-simple', github: 'hone/mruby-fileutils-simple'
  spec.add_dependency 'mruby-io',               github: 'hone/mruby-io',      branch: 'popen_status'
  spec.add_dependency 'mruby-process',          github: 'hone/mruby-process', branch: 'header'
  spec.add_test_dependency 'mruby-stringio', mgem: 'mruby-stringio'
  spec.add_test_dependency 'mruby-tempfile', mgem: 'mruby-tempfile'
  spec.add_test_dependency 'mruby-mtest',    mgem: 'mruby-mtest'
end
