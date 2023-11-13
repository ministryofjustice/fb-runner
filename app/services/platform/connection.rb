module Platform
  module Connection
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 30

    private

    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Runner',
        'X-Request-Id' => request_id,
        # Datastore still uses the v2 access token from service token cache
        'x-access-token-v2' => service_access_token
      }
    end

    def connection
      @connection ||= Faraday.new(root_url) do |conn|
        conn.request :json
        conn.response :json
        conn.response :raise_error
        conn.use :instrumentation, name: subscription

        # Number of seconds to wait for the connection to open
        conn.options.open_timeout = open_timeout

        # Number of seconds to wait for one block to be read
        conn.options.read_timeout = read_timeout

        # Submitter uses the v3 access token from service token cache
        conn.request :authorization, 'Bearer', service_access_token
      end
    end

    def data_encryption
      @data_encryption ||= DataEncryption.new(key: encryption_key)
    end

    def saved_form_data_encryption
      @saved_form_data_encryption ||= DataEncryption.new(key: saved_form_encryption_key)
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new(
        subject:
      ).generate
    end

    def subject
      session[:user_id]
    end
    alias_method :user_id, :subject

    def open_timeout
      DEFAULT_OPEN_TIMEOUT
    end

    def read_timeout
      DEFAULT_READ_TIMEOUT
    end

    def request(verb, url, body)
      connection.send(verb, url, body, headers)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise Platform::TimeoutError, error_message(e)
    rescue Faraday::ResourceNotFound => e
      raise Platform::ResourceNotFound, error_message(e)
    rescue StandardError => e
      raise Platform::ClientError, e
    end

    def request_id
      session.instance_variable_get(:@req).try(:request_id)
    end

    def error_message(exception)
      "App: #{self.class.name}. #{exception.message}"
    end
  end
end
