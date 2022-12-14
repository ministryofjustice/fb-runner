class ApplicationController < ActionController::Base
  include ReferenceNumberHelper
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
    @load_user_data ||= reload_user_data
  end

  def reload_user_data
    UserData.new(session).load_data
  end

  def remove_user_data(component_id)
    UserData.new(session).delete(component_id)
  end

  def upload_adapter
    if ENV['USER_FILESTORE_URL'].blank?
      raise Platform::MissingFilestoreUrlError if Rails.env.production?

      MetadataPresenter::OfflineUploadAdapter
    else
      Platform::UserFilestoreAdapter
    end
  end

  def update_session_with_reference_number_if_enabled(session)
    return load_user_data unless reference_number_enabled?

    user_data = load_user_data.merge(reference_number_session_data)
    # rubocop: disable Rails/SaveBang
    UserData.new(session).save(user_data)
    # rubocop: enable Rails/SaveBang
    user_data
  end

  def create_submission
    user_data = update_session_with_reference_number_if_enabled(session)
    # rubocop: disable Rails/SaveBang
    Platform::Submission.new(
      service: service,
      user_data: user_data,
      session: session
    ).save
    # rubocop: enable Rails/SaveBang
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

  def autocomplete_items(components)
    return {} if Rails.configuration.autocomplete_items.nil?

    components.each_with_object({}) do |component, hash|
      next unless component.autocomplete?

      hash[component.uuid] = Rails.configuration.autocomplete_items[component.uuid]
    end
  end

  def reference_number_session_data
    @reference_number_session_data ||= { 'moj_forms_reference_number' => generate_reference_number }
  end

  def reference_number_enabled?
    ENV['REFERENCE_NUMBER'].present?
  end
  helper_method :reference_number_enabled?

  def show_reference_number
    load_user_data['moj_forms_reference_number']
  end
  helper_method :show_reference_number

  def payment_link_enabled?
    ENV['PAYMENT_LINK'].present?
  end
  helper_method :payment_link_enabled?
end
