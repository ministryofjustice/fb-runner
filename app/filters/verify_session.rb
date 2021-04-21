class VerifySession
  def self.before(controller)
    if !allowed_pages?(controller) && controller.session[:session_id].blank?
      controller.reset_session
      controller.redirect_to controller.root_path
    end
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
