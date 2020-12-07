class ServiceAccessToken
  attr_reader :encoded_private_key, :issuer, :namespace, :subject

  def initialize(subject: nil, encoded_private_key: ENV['ENCODED_PRIVATE_KEY'])
    @encoded_private_key = encoded_private_key
    @issuer = 'fb-runner'
    @namespace = 'formbuilder-services-live-production'
    @subject = subject
  end

  def generate
    return if encoded_private_key.blank?

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
      namespace: namespace,
      iat: Time.current.to_i,
    }
    payload[:sub] = subject if subject.present?
    payload
  end
end
