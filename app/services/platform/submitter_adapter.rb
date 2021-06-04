module Platform
  class SubmitterAdapter
    include Platform::Connection
    include Platform::EncryptedUserIdAndToken
    attr_reader :payload, :session, :root_url, :service_slug, :service_secret

    SUBSCRIPTION = 'submitter.request'.freeze
    TIMEOUT = 15
    V2_URL = '/v2/submissions'.freeze

    def initialize(payload:,
                   service_slug:,
                   session:,
                   service_secret: ENV['SERVICE_SECRET'],
                   root_url: ENV['SUBMITTER_URL'])
      @payload = payload
      @service_slug = service_slug
      @session = session
      @service_secret = service_secret
      @root_url = root_url
    end

    def save
      request(:post, V2_URL, request_body)
    end

    def request_body
      {
        encrypted_submission: data_encryption.encrypt(payload.to_json),
        service_slug: service_slug,
        encrypted_user_id_and_token: encrypted_user_id_and_token
      }
    end

    def encryption_key
      ENV['SUBMISSION_ENCRYPTION_KEY']
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new(
        issuer: service_slug,
        subject: subject
      ).generate
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      TIMEOUT
    end

    def subject
      session[:session_id]
    end
    alias_method :user_id, :subject
  end
end
