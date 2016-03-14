RSpec.describe "help" do
  it "should work with short form" do
    output, _, status = run_bin("-h")

    expect(status).to be_success
    expect(output).to include("Usage:")
  end

  it "should work with long form" do
    output, _, status = run_bin("--help")

    expect(status).to be_success
    expect(output).to include("Usage:")
  end
end
