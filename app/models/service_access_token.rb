class ServiceAccessToken
  ISSUER = 'fb-runner'
  attr_reader :encoded_private_key, :issuer, :subject

  def initialize(subject: nil, encoded_private_key: ENV['ENCODED_PRIVATE_KEY'])
    @encoded_private_key = encoded_private_key
    @issuer = ISSUER
    @subject = subject
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
    if ENV['PLATFORM_ENV'].present? && ENV['DEPLOYMENT_ENV'].present?
      "formbuilder-services-#{ENV['PLATFORM_ENV']}-#{ENV['DEPLOYMENT_ENV']}"
    end
  end
end
