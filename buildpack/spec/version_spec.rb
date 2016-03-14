RSpec.describe "version" do
  it "should respect the short form" do
    output, _, status = run_bin("-v")

    expect(status).to be_success
    expect(output.chomp).to eq("v0.0.1")
  end

  it "should respect the long form" do
    output, _, status = run_bin("--version")

    expect(status).to be_success
    expect(output.chomp).to eq("v0.0.1")
  end
end
