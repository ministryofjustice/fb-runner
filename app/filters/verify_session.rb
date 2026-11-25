class VerifySession
  def self.before(controller)
    return if controller.is_a?(MetadataPresenter::AuthController)

    # if the user has just submitted their form we reset the session
    # if they try to visit any page other than the homepage, redirect them to submission complete page
    if controller.flash[:submission_completed].present?
      controller.reset_session
      controller.redirect_to '/session/complete' unless request_root_path?(controller)
    end

    # after saving form progress
    if controller.flash[:session_destroyed].present?
      controller.reset_session
      controller.redirect_to '/session/destroyed' unless request_root_path?(controller)
    end

    # if we are on a page that requires a session and it has been marked as expired
    if !controller.allowed_page? && controller.flash[:expired_session].present?
      reset_session_then_redirect(controller)
    end

    # We need the session on the confirmation page, but want to get rid of it after
    if !controller.allowed_page? && controller.flash[:confirmation].present?
      controller.flash[:submission_completed] = 'Submission completed'
    end

    if !controller.allowed_page? && controller.session[:session_id].blank?
      reset_session_then_redirect(controller)
    end

    controller.session[:expire_after] = controller.class::SESSION_DURATION
    controller.session[:expires_at] = Time.zone.now + controller.class::SESSION_DURATION
  end

  def self.request_root_path?(controller)
    controller.request.path == controller.root_path
  end

  def self.reset_session_then_redirect(controller)
    controller.reset_session
    controller.redirect_to '/session/expired'
  end

  private_class_method :request_root_path?, :reset_session_then_redirect
end
