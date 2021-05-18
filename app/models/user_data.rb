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

    if ENV['DATASTORE_URL'].present?
      Platform::UserDatastoreAdapter.new(session)
    else
      SessionDataAdapter.new(session)
    end
  end
end
