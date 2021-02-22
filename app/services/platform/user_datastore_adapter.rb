module Platform
  class UserDatastoreAdapter
    TIMEOUT = 15
    SUBSCRIPTION = 'datastore.request'

    include Platform::Connection

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

      request(:post, url, body)
    end

    def load_data
      response = request(:get, url, {}).body['payload'] || {}

      JSON.parse(data_encryption.decrypt(response)) || {}
    rescue Platform::ResourceNotFound
      {}
    end

    def data_encryption
      @data_encryption = DataEncryption.new(key: encryption_key)
    end

    private

    def url
      "/service/#{service_slug}/user/#{subject}"
    end

    def encryption_key
      session[:user_token] ||= SecureRandom.uuid.gsub('-', '')
    end

    def subject
      session[:session_id]
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      TIMEOUT
    end
  end
end
