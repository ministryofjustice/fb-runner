module Platform
  class UserDatastoreAdapter
    class DatastoreTimeoutError < StandardError; end
    class DatastoreClientError < StandardError; end
    class DatastoreResourceNotFound < StandardError; end
    TIMEOUT = 15
    SUBSCRIPTION = 'datastore.request'

    attr_reader :session, :root_url, :service_slug

    def initialize(session, root_url: ENV['DATASTORE_URL'], service_slug: ENV['SERVICE_SLUG'])
      @session = session
      @root_url = root_url
      @service_slug = service_slug
    end

    def save(params)
      existing_answers = load_data
      all_answers = existing_answers.merge(params)

      body = {
        payload: data_encryption.encrypt(all_answers.to_json)
      }

      request(:post, body)
    end

    def load_data
      response = request(:get, {}).body['payload'] || {}

      JSON.parse(data_encryption.decrypt(response)) || {}
    rescue DatastoreResourceNotFound
      {}
    end

    private

    def data_encryption
      @data_encryption = DataEncryption.new(key: user_token)
    end

    def url
      "/service/#{service_slug}/user/#{subject}"
    end

    def subject
      session[:session_id]
    end

    def user_token
      session[:user_token] ||= SecureRandom.uuid.gsub('-', '')
    end

    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Runner',
        'x-access-token-v2' => service_access_token
      }
    end

    def connection
      @connection ||= Faraday.new(root_url) do |conn|
        conn.request :json
        conn.response :json
        conn.response :raise_error
        conn.use :instrumentation, name: SUBSCRIPTION
        conn.options[:open_timeout] = TIMEOUT
        conn.options[:timeout] = TIMEOUT

        conn.authorization :Bearer, service_access_token
      end
    end

    def request(verb, body)
      connection.send(verb, url, body, headers)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => exception
      raise DatastoreTimeoutError.new(exception.message)
    rescue Faraday::ResourceNotFound => exception
      raise DatastoreResourceNotFound.new(exception.message)
    rescue StandardError => exception
      raise DatastoreClientError.new(exception.message)
    end

    def service_access_token
      @service_access_token ||= Fb::Jwt::Auth::ServiceAccessToken.new(subject: subject).generate
    end
  end
end
