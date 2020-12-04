class SessionDataAdapter
  attr_reader :session

  def initialize(session)
    @session = session
  end

  def save(params)
    if params[:answers]
      session[:user_data] ||= {}

      params[:answers].each do |field, answer|
        session[:user_data][field] = answer
      end
    end
  end

  def load_data
    session[:user_data] || {}
  end
end
