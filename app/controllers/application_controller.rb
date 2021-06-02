class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_basic_auth
  before_action VerifySession

  EXCEPTIONS = [
    Platform::TimeoutError,
    Platform::ClientError
  ].freeze
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
    UserData.new(session).save(user_data_params)
  end

  def user_data_params
    UserDataParams.new(@page_answers).answers
  end

  def load_user_data
    UserData.new(session).load_data
  end

  def upload_file
    user_data = load_user_data
    @page_answers.page.upload_components.each do |component|

      file = if user_data[component.id] && user_data[component.id]['original_filename']
               @page_answers.answers[component.id] = OpenStruct.new(
          original_filename: user_data[component.id]['original_filename'],
          tempfile: OpenStruct.new(path: user_data[component.id]['tempfile']),
          content_type: user_data[component.id]['content_type']
        )
               UploadedFile.new(file: user_data[component.id], component: component)

      else
        FileUploader.new(
          session: session,
          page_answers: @page_answers,
          component: component
        ).upload
      end

      @page_answers.uploaded_files.push(file)
    end
  end

  def create_submission
    Platform::Submission.new(
      service: service,
      user_data: load_user_data,
      session: session
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
