module Platform
  class SubmitterAdapter
    include Platform::Connection
    attr_reader :payload, :root_url

    SUBSCRIPTION = 'submitter.request'.freeze
    TIMEOUT = 15
    V2_URL = '/v2/submissions'

    def initialize(payload:,
                   root_url: ENV['SUBMITTER_URL']
                   )
      @payload = payload
      @root_url = root_url
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

    def subject
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      TIMEOUT
    end
  end
end
