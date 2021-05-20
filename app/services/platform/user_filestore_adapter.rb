module Platform
  class FilestoreError
    include ActiveModel::Model
    attr_accessor :status, :body

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
      root_url: ENV['FILESTORE_URL'],
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
      request(:post, url, payload)
    rescue Platform::ClientError => e
      response = e.response

      FilestoreError.new(
        status: response[:status], body: JSON.parse(response[:body])
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
