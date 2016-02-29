assert('-h') do
  output, error, status = Support.run_bin('-h')

  assert_true status.success?
  assert_include output, "Usage:"
end

assert('--help') do
  output, error, status = Support.run_bin('--help')

  assert_true status.success?
  assert_include output, "Usage:"
end
