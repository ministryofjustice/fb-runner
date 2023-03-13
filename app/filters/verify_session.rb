class VerifySession
  def self.before(controller)
    if !allowed_pages?(controller) && controller.flash[:expired_session].present?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end
    if !allowed_pages?(controller) && controller.flash[:confirmation].present?
      controller.flash[:expired_session] = 'Session has expired'
    end
    if !allowed_pages?(controller) && controller.session[:session_id].blank?
      controller.reset_session
      controller.redirect_to '/session/expired'
    end
    controller.session[:expire_after] = 20.minutes
  end

  def self.allowed_pages?(controller)
    urls = controller.service.standalone_pages.map do |page|
      strip_url(page.url)
    end

    controller.request.path == controller.root_path ||
      urls.include?(strip_url(controller.request.path))
  end

  def self.strip_url(url)
    url.to_s.chomp('/').reverse.chomp('/').reverse
  end
end
