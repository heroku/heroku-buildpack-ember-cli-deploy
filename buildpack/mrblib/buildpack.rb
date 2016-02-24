def __main__(argv)
  Buildpack::CLI.new(argv, $stdout, $stderr).run
end
