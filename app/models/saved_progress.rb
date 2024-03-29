class MissingDatastoreUrlError < StandardError
end

class SavedProgress
  attr_reader :session

  delegate :save_progress, :get_saved_progress, :load_data, :delete, :increment_record_counter, :invalidate, to: :adapter

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
    session[:user_token] ||= SecureRandom.hex(16)
    session[:user_id] ||= SecureRandom.hex(16)
  end
end
