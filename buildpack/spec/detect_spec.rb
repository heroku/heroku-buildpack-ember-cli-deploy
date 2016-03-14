RSpec.describe "detect" do
  it "should detect ember-cli-deploy" do
    output, _, status = run_bin('detect', fixtures("github-issues-demo-deploy"))

    expect(status).to be_success
    expect(output.chomp).to eq("ember-cli-deploy")
  end

  it "detect ember-cli app" do
    output, _, status = run_bin('detect', fixtures("github-issues-demo"))

    expect(status).to be_success
    expect(output.chomp).to eq("ember-cli")
  end

  it "not ember-cli-deploy app" do
    _, _, status = run_bin('detect', fixtures("wywh"))

    expect(status).not_to be_success
  end

  it "missing package.json" do
    _, _, status = run_bin('detect', fixtures("not-static"))

    expect(status).not_to be_success
  end
end
