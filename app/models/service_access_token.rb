class ServiceAccessToken
  ISSUER = 'fb-runner'
  attr_reader :encoded_private_key, :issuer, :subject, :platform_env, :deployment_env

  def initialize(subject: nil, encoded_private_key: ENV['ENCODED_PRIVATE_KEY'], platform_env: ENV['PLATFORM_ENV'], deployment_env: ENV['DEPLOYMENT_ENV'])
    @encoded_private_key = encoded_private_key
    @issuer = ISSUER
    @subject = subject
    @platform_env = platform_env
    @deployment_env = deployment_env
  end

  def generate
    return '' if encoded_private_key.blank?

    private_key = OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_private_key.chomp))

    JWT.encode(
      token,
      private_key,
      'RS256'
    )
  end

  private

  def token
    payload = {
      iss: issuer,
      iat: Time.current.to_i
    }
    payload[:sub] = subject if subject.present?
    payload[:namespace] = namespace if namespace.present?
    payload
  end

  def namespace
    return if platform_env.blank? || deployment_env.blank?

    "formbuilder-services-#{platform_env}-#{deployment_env}"
  end
end
