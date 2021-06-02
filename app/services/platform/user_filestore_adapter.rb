module Platform
  class FilestoreError
    include ActiveModel::Model
    attr_accessor :status, :error_name

    def error?
      true
    end
  end

  class UserFilestoreAdapter
    include Platform::Connection
    attr_reader :session, :root_url, :service_slug, :payload

    SUBSCRIPTION = 'filestore.upload'.freeze

    def initialize(
      session,
      payload:,
      root_url: ENV['USER_FILESTORE_URL'],
      service_slug: ENV['SERVICE_SLUG']
    )
      @session = session
      @root_url = root_url
      @service_slug = service_slug
      @payload = payload
    end

    def call
      return if root_url.blank?

      url = "/service/#{service_slug}/user/#{subject}"
      request(:post, url, payload).body
    rescue Platform::ClientError => e
      response = e.response
      response_body = JSON.parse(response[:body], symbolize_names: true)

      FilestoreError.new(
        status: response[:status], error_name: response_body[:name]
      )
    end

    def subject
      session[:session_id]
    end

    def subscription
      SUBSCRIPTION
    end

    def timeout
      10
    end
  end
end
