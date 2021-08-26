class MissingDatastoreUrlError < StandardError
end

class UserData
  attr_reader :session

  delegate :save, :load_data, :delete, to: :adapter

  def initialize(session, adapter: nil)
    @session = session
    @adapter = adapter
  end

  def adapter
    create_user_keys
    return @adapter.new(session) if @adapter.present?

    if ENV['USER_DATASTORE_URL'].present?
      Platform::UserDatastoreAdapter.new(session)
    else
      raise MissingDatastoreUrlError if Rails.env.production?

      SessionDataAdapter.new(session)
    end
  end

  def create_user_keys
    if session[:user_token].present?
      # backwards compatibility to avoid erasing user data during the deployment
      session[:user_id] ||= session[:session_id]
    end

    session[:user_token] ||= SecureRandom.hex(16)
    session[:user_id] ||= SecureRandom.hex(16)
  end
end
