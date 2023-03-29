class VerifySession
  def self.before(controller)
    if !controller.allowed_page? && controller.flash[:expired_session].present?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end

    if !controller.allowed_page? && controller.flash[:confirmation].present?
      controller.flash[:expired_session] = 'Session has expired'
    end

    if !controller.allowed_page? && controller.session[:session_id].blank?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end

    controller.session[:expire_after] = controller.class::SESSION_DURATION
    controller.session[:expires_at] = Time.zone.now + controller.class::SESSION_DURATION
  end
end
