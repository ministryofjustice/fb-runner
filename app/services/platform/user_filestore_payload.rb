module Platform
  class UserFilestorePayload
    attr_reader :session, :file_details, :service_secret, :allowed_file_types

    DEFAULT_EXPIRATION = 28
    ALLOWED_TYPES = %w[
      text/csv
      text/plain
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/msword
      application/vnd.oasis.opendocument.text
      application/pdf
      application/rtf
      image/jpeg
      image/png
      application/vnd.ms-excel
    ].freeze
    MAX_FILE_SIZE = 7_340_032

    def initialize(session, file_details:, allowed_file_types:, service_secret: ENV['SERVICE_SECRET'])
      @session = session
      @file_details = file_details
      @service_secret = service_secret
      @allowed_file_types = allowed_file_types
    end

    def call
      {
        'encrypted_user_id_and_token': encrypted_user_id_and_token,
        'file': encoded_file,
        'policy': {
          'allowed_types': allowed_types,
          'max_size': MAX_FILE_SIZE,
          'expires': expires
        }
      }
    end

    def expires
      DEFAULT_EXPIRATION
    end

    def allowed_types
      allowed_file_types || ALLOWED_TYPES
    end

    def temp_file
      File.open(file_details['tempfile']).read
    end

    def encoded_file
      Base64.strict_encode64(temp_file)
    end

    def encrypted_user_id_and_token
      DataEncryption.new(
        key: service_secret
      ).encrypt("#{user_id}#{session[:user_token]}")
    end

    private

    def user_id
      session[:session_id]
    end
  end
end
