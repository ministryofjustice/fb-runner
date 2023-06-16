module Platform
  class UserDatastoreAdapter
    include Platform::Connection
    TIMEOUT = 30
    SUBSCRIPTION = 'datastore.request'.freeze

    attr_reader :session, :root_url, :service_slug

    def initialize(session, root_url: ENV['USER_DATASTORE_URL'], service_slug: ENV['SERVICE_SLUG'])
      @session = session
      @root_url = root_url
      @service_slug = service_slug
    end

    def save(params)
      existing_answers = load_data
      # byebug
      all_answers = existing_answers.merge(params)

      yield(all_answers) if block_given?

      body = {
        payload: data_encryption.encrypt(all_answers.to_json)
      }

      request(:post, url, body)
    end

    def get_saved_progress(uuid)
      begin
        result = request(:get, save_form_get_url(uuid), {})
      rescue Platform::ClientError => e
        if e.response[:status] == 400
          return OpenStruct.new(status: 400)
        end
        if e.response[:status] == 422
          return OpenStruct.new(status: 422)
        end
      rescue Platform::ResourceNotFound
        return OpenStruct.new(status: 404)
      end

      result.body['email'] = saved_form_data_encryption.decrypt(result.body['email'])
      result.body['user_id'] = saved_form_data_encryption.decrypt(result.body['user_id'])
      result.body['user_token'] = saved_form_data_encryption.decrypt(result.body['user_token'])
      result.body['secret_answer'] = saved_form_data_encryption.decrypt(result.body['secret_answer'])

      result
    end

    def save_progress
      saved_form = session[:saved_form].clone

      saved_form['user_id'] = saved_form_data_encryption.encrypt(saved_form['user_id'])
      saved_form['user_token'] = saved_form_data_encryption.encrypt(saved_form['user_token'])
      saved_form['email'] = saved_form_data_encryption.encrypt(saved_form['email'])
      saved_form['secret_answer'] = saved_form_data_encryption.encrypt(saved_form['secret_answer'])

      request(:post, save_form_url, saved_form.to_json)
    end

    def increment_record_counter(uuid)
      request(:post, save_form_increment_url(uuid), {})
    rescue Platform::ClientError => e
      if e.response[:status] == 422
        OpenStruct.new(status: 422)
      end
    rescue Platform::ResourceNotFound
      OpenStruct.new(status: 404)
    end

    def invalidate(uuid)
      request(:post, save_form_invalidate_url(uuid), {})
    rescue Platform::ClientError => e
      if e.response[:status] == 422
        OpenStruct.new(status: 422)
      end
    rescue Platform::ResourceNotFound
      OpenStruct.new(status: 404)
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

    def save_form_get_url(subject)
      "/service/#{service_slug}/saved/#{subject}"
    end

    def save_form_increment_url(subject)
      "/service/#{service_slug}/saved/#{subject}/increment"
    end

    def save_form_invalidate_url(subject)
      "/service/#{service_slug}/saved/#{subject}/invalidate"
    end

    def save_form_url
      "/service/#{service_slug}/saved/"
    end

    def encryption_key
      session[:user_token]
    end

    def saved_form_encryption_key
      ENV['SUBMISSION_ENCRYPTION_KEY']
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      TIMEOUT
    end
  end
end
