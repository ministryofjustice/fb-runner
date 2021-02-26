module Platform
  class SubmitterAdapter
    include Platform::Connection
    attr_reader :payload, :root_url, :service_slug

    SUBSCRIPTION = 'submitter.request'.freeze
    TIMEOUT = 15
    V2_URL = '/v2/submissions'

    def initialize(payload:,
                   service_slug:,
                   root_url: ENV['SUBMITTER_URL']
                   )
      @payload = payload
      @root_url = root_url
      @service_slug = service_slug
    end

    def save
      request(:post, V2_URL, encrypted_submission)
    end

    def encrypted_submission
      { encrypted_submission: data_encryption.encrypt(payload.to_json) }
    end

    def encryption_key
      ENV['SUBMISSION_ENCRYPTION_KEY']
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new(
        issuer: service_slug
      ).generate
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      TIMEOUT
    end
  end
end
