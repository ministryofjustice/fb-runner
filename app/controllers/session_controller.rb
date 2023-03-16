class SessionController < ApplicationController
  skip_before_action :require_basic_auth
  skip_before_action VerifySession

  def remaining
    remaining = (Time.rfc3339(session[:expires_at]) - Time.zone.now).to_i
    render plain: remaining
  end

  def extend
    reset_session
    session[:expires_at] = Time.zone.now + SESSION_DURATION
    head :ok
  end
end
