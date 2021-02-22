module Platform
  module Connection
    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Runner',
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
        conn.options[:open_timeout] = timeout
        conn.options[:timeout] = timeout

        # Submitter uses the v3 access token from service token cache
        conn.authorization :Bearer, service_access_token
      end
    end

    def data_encryption
      @data_encryption ||= DataEncryption.new(key: encryption_key)
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new(
        subject: subject
      ).generate
    end

    def request(verb, url, body)
      connection.send(verb, url, body, headers)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => exception
      raise Platform::TimeoutError.new(error_message(exception))
    rescue Faraday::ResourceNotFound => exception
      raise Platform::ResourceNotFound.new(error_message(exception))
    rescue StandardError => exception
      raise Platform::ClientError.new(error_message(exception))
    end

    def error_message(exception)
      "App: #{self.class.name}. #{exception.message}"
    end
  end
end
