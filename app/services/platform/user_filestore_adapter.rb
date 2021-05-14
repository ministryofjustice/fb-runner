module Platform
  class UserFilestoreAdapter
    include Platform::Connection
    attr_reader :session, :root_url, :service_slug, :payload

    def initialize(
      session,
      root_url: ENV['FILESTORE_URL'],
      service_slug: ENV['SERVICE_SLUG'],
      payload:
    )
      @session = session
      @root_url = root_url
      @service_slug = service_slug
      @payload = payload
    end

    def call
      return if root_url.blank?

      # use the subject as the same as user_id which is on the url
      # /service/:service_slug/user/:subject
      # response = upload_to_file_store_using_same_user_id_from_session

      # this will be used when sending the submission
      # save_filestore_response_to_user_datastore(response)

#      http://localhost:3000
#      /service/some-service/user/some-user/28d-e71c352d0852ab802592a02168877dc255d9c839a7537d91efed04a5865549c1?payload=#{query_string_payload}
    end
  end
end
