Fb::Jwt::Auth.configure do |config|
  config.issuer = ENV['SERVICE_SLUG']
  config.namespace = "formbuilder-services-#{ENV['PLATFORM_ENV']}-#{ENV['DEPLOYMENT_ENV']}"
  config.encoded_private_key = ENV['ENCODED_PRIVATE_KEY']
end
