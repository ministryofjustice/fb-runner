module Platform
  class SubmitterAdapter
    include Platform::Connection
    attr_reader :payload, :session, :root_url, :service_slug

    SUBSCRIPTION = 'submitter.request'.freeze
    TIMEOUT = 15
    V2_URL = '/v2/submissions'.freeze

    def initialize(payload:,
                   service_slug:,
                   session:,
                   root_url: ENV['SUBMITTER_URL'])
      @payload = payload
      @root_url = root_url
      @service_slug = service_slug
      @session = session
    end

    def save
      request(:post, V2_URL, request_body)
    end

    def request_body
      {
        encrypted_submission: data_encryption.encrypt(payload.to_json),
        service_slug: service_slug,
        encrypted_user_id_and_token: subject
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
  end
end
