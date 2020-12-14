class ApplicationController < ActionController::Base
  EXCEPTIONS = [
    UserDatastoreAdapter::DatastoreTimeoutError,
    UserDatastoreAdapter::DatastoreClientError
  ]
  rescue_from(*EXCEPTIONS) do |exception|
    render file: 'public/500.html', status: 500
  end
  layout 'metadata_presenter/application'

  def service
    @service ||= Rails.configuration.service
  end
  helper_method :service

  def save_user_data
    UserData.new(session).save(answer_params)
  end

  def load_user_data
    UserData.new(session).load_data
  end

  def answer_params
    params.permit(:answers => {})[:answers] || {}
  end
end
