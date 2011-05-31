def load_credentials(key)
  YAML.load_file(File.join(File.dirname(__FILE__),'..','credentials.yml'))[key]
end

RSpreedlyCore::Config.setup do |config|
  config[:api_login] = load_credentials('api_login')
  config[:api_secret] = load_credentials('api_secret')
  config[:gateway_token] = load_credentials('gateway_token')
end
