class ApplicationController < ActionController::Base
  def service
    Rails.configuration.service
  end
  helper_method :service

  def service_metadata
    Rails.configuration.service_metadata
  end

  def save_user_data
  end

  def load_user_data
  end
end
