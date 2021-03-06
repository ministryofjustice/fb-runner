module Platform
  class UserDatastoreAdapter
    include Platform::Connection
    TIMEOUT = 15
    SUBSCRIPTION = 'datastore.request'.freeze

    attr_reader :session, :root_url, :service_slug

    def initialize(session, root_url: ENV['USER_DATASTORE_URL'], service_slug: ENV['SERVICE_SLUG'])
      @session = session
      @root_url = root_url
      @service_slug = service_slug
    end

    def save(params)
      existing_answers = load_data
      all_answers = existing_answers.merge(params)

      yield(all_answers) if block_given?

      body = {
        payload: data_encryption.encrypt(all_answers.to_json)
      }

      request(:post, url, body)
    end

    def load_data
      response = request(:get, url, {}).body['payload']

      JSON.parse(data_encryption.decrypt(response))
    rescue Platform::ResourceNotFound
      {}
    end

    def delete(component_id)
      save({}) do |all_answers|
        all_answers.delete(component_id)
      end
    end

    private

    def url
      "/service/#{service_slug}/user/#{subject}"
    end

    def encryption_key
      session[:user_token]
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
