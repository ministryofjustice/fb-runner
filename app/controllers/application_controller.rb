class ApplicationController < ActionController::Base
  layout 'metadata_presenter/application'

  def service
    @service ||= Rails.configuration.service
  end
  helper_method :service

  def save_user_data
    UserData.new(session).save(params.permit(answers: {})[:answers] || {})
  end

  def load_user_data
    UserData.new(session).load_data
  end
end
