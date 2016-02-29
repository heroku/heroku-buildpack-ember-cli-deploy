class Buildpack::Commands::Compile::DefaultStaticConfig
  def initialize(output_io, error_io)
    @output_io = output_io
    @error_io  = error_io
  end

  def write(config_path, ember_cli_deploy)
    contents = default_static_json(config_path, ember_cli_deploy)
    if contents
      @output_io.topic "Writing static.json"
      File.open(config_path, 'w') do |file|
        file.puts contents
      end
    end

    true
  rescue JSON::ParserError => e
    @error_io.puts "static.json is not valid JSON"
    false
  end

  private
  def default_static_json(config_path, ember_cli_deploy)
    config = StaticConfig.new(File.exist?(config_path) ? File.read(config_path) : "{}", ember_cli_deploy)

    if !config.write?
      nil
    else
      config.to_json
    end
  end
end
