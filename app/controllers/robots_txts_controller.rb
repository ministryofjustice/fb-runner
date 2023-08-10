class RobotsTxtsController < ApplicationController
  # skip_before_action :require_basic_auth, VerifySession

  def show
    if deny_all_crawlers?
      render template: :deny_all, layout: false, content_type: 'text/plain'
    else
      render body: nil, status: :not_found
    end
  end

  private

  def deny_all_crawlers?
    Rails.application.config.deny_all_web_crawlers
  end
end
