class SessionController < ApplicationController
  skip_before_action :require_basic_auth
  # skip_before_action VerifySession

  def extend
    session[:expire_after] = SESSION_DURATION
    session[:expires_at] = Time.zone.now + SESSION_DURATION
    head :ok
  end

  def reset
    reset_session
    if request.xhr?
      head :ok
    else
      redirect_to '/session/expired'
    end
  end
end
