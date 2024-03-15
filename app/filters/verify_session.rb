class VerifySession
  def self.before(controller)
    return if controller.is_a?(MetadataPresenter::AuthController)

    # if the user has just submitted their form we reset the session
    # if they try to visit any page other than the homepage, redirect them to submission complete page
    if controller.flash[:submission_completed].present?
      controller.reset_session
      controller.redirect_to '/session/complete' unless controller.request.path == controller.root_path
    end

    # if we are on a page that requires a session and it has been marked as expired
    if !controller.allowed_page? && controller.flash[:expired_session].present?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end

    # We need the session on the confirmtion page, but want to get rid of it after
    if !controller.allowed_page? && controller.flash[:confirmation].present?
      # controller.flash[:expired_session] = 'Session has expired'
      controller.flash[:submission_completed] = 'Submission completed'
    end

    if !controller.allowed_page? && controller.session[:session_id].blank?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end

    controller.session[:expire_after] = controller.class::SESSION_DURATION
    controller.session[:expires_at] = Time.zone.now + controller.class::SESSION_DURATION
  end
end
