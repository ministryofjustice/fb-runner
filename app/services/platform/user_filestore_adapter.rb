module Platform
  class UserFilestoreAdapter
    def initialize(session, root_url: ENV['FILESTORE_URL'], service_slug: ENV['SERVICE_SLUG'], payload:)
      @session = session
      @root_url = root_url
      @service_slug = service_slug
      @payload = payload
    end

    def upload(params)
    end
  end
end
