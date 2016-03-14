require_relative 'helpers/support'

assert('-v') do
  output, error, status = Support.run_bin("-v")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v0.0.1"
end

assert('--version') do
  output, error, status = Support.run_bin("--version")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v0.0.1"
end
