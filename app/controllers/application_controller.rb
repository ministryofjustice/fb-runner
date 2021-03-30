class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_basic_auth

  EXCEPTIONS = [
    Platform::TimeoutError,
    Platform::ClientError
  ]
  rescue_from(*EXCEPTIONS) do |exception|
    Rails.logger.info(exception.message)
    Sentry.capture_exception(exception)
    render file: 'public/500.html', status: :internal_server_error
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

  def create_submission
    Platform::Submission.new(
      service: service,
      user_data: load_user_data
    ).save
  end

  def editable?
    false
  end
  helper_method :editable?

  def answer_params
    params.permit(answers: {})[:answers] || {}
  end

  def require_basic_auth
    if ENV['BASIC_AUTH_USER'].present? && ENV['BASIC_AUTH_PASS'].present?
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASS']
      end
    end
  end
end
