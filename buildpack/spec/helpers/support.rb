require 'open3'
require 'pathname'
require 'fileutils'

module Support
  BIN_PATH = File.join(File.dirname(__FILE__), "../../mruby/bin/buildpack")

  def run_bin(*options)
    Open3.capture3(BIN_PATH, *options)
  end

  def fixtures(path)
    (Pathname.new(File.join(File.dirname(__FILE__), "../../fixtures")) + path).expand_path.to_s
  end
end
