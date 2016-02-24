assert('detect ember-cli-deploy') do
  output, status = Support.run_bin('detect', Support.fixtures("github-issues-demo"))

  assert_true status.success?
  assert_include output, "ember-cli-deploy"
end

assert('not ember-cli-deploy app') do
  output, status = Support.run_bin('detect', Support.fixtures("wywh"))

  assert_false status.success?
end

assert('missing package.json') do
  output, status = Support.run_bin('detect', Support.fixtures("not-static"))

  assert_false status.success?
end
