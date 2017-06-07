module Buildpack
  class StaticConfig
    DEFAULT_EMBER_CLI_DEPLOY_DIR = "tmp/deploy-dist"
    DEFAULT_EMBER_CLI_DIR        = "dist"
    DEFAULT_EMBER_ENV            = "production"
    WRITEABLE_KEYS               = Set.new(%w(root routes))

    def initialize(contents = "{}", ember_cli_deploy = false)
      @json             = parse(contents)
      @ember_cli_deploy = ember_cli_deploy
    end

    def write?
      (Set.new(@json.keys) & WRITEABLE_KEYS) != WRITEABLE_KEYS
    end

    def to_json
      @json['root'] ||= @ember_cli_deploy ? DEFAULT_EMBER_CLI_DEPLOY_DIR : DEFAULT_EMBER_CLI_DIR
      @json['routes'] ||= {
        '/**' => 'index.html'
      }
      JSON.generate(@json, {
        :pretty_print => true,
        :indent       => 2
      })
    end

    private
    def parse(contents)
      JSON.parse(contents)
    end
  end
end
