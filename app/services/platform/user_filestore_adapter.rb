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
    attr_reader :session, :root_url, :service_slug

    SUBSCRIPTION = 'filestore.upload'.freeze
    READ_TIMEOUT = 90 # seconds

    def initialize(
      session:,
      file_details:,
      allowed_file_types:,
      root_url: ENV['USER_FILESTORE_URL'],
      service_slug: ENV['SERVICE_SLUG']
    )
      @session = session
      @root_url = root_url
      @file_details = file_details
      @allowed_file_types = allowed_file_types
      @service_slug = service_slug
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

    def subscription
      SUBSCRIPTION
    end

    def read_timeout
      READ_TIMEOUT
    end

    def payload
      UserFilestorePayload.new(
        session: @session,
        file_details: @file_details,
        allowed_file_types: @allowed_file_types
      ).call
    end
  end
end
