class MissingDatastoreUrlError < StandardError
end

class UserData
  attr_reader :session

  delegate :save, :load_data, to: :adapter

  def initialize(session, adapter: nil)
    @session = session
    @adapter = adapter
  end

  def adapter
    session[:user_token] ||= SecureRandom.hex(16)

    return @adapter.new(session) if @adapter.present?

    if ENV['USER_DATASTORE_URL'].present?
      Platform::UserDatastoreAdapter.new(session)
    else
      raise MissingDatastoreUrlError if Rails.env.production?

      SessionDataAdapter.new(session)
    end
  end
end
