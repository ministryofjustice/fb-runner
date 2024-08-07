class ApplicationController < ActionController::Base
  include ReferenceNumberHelper
  protect_from_forgery with: :exception

  before_action VerifySession

  add_flash_types :confirmation, :expired_session, :submission_completed, :session_destroyed
  rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_to_expired_page

  SESSION_DURATION = 30.minutes

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

  def save_form_progress
    SavedProgress.new(session).save_progress
  end

  def get_saved_progress(uuid)
    SavedProgress.new(session).get_saved_progress(uuid)
  end

  def increment_record_counter(uuid)
    SavedProgress.new(session).increment_record_counter(uuid)
  end

  def invalidate_record(uuid)
    SavedProgress.new(session).invalidate(uuid)
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

  def remove_file_from_data(component_id, file_id)
    UserData.new(session).delete_file(component_id, file_id)
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
      service:,
      user_data:,
      session:
    ).save
    # rubocop: enable Rails/SaveBang

    delete_session
  end

  def create_save_and_return_submission(user_data)
    Platform::SaveAndReturn.new(
      service:,
      user_data:,
      session:
    ).save
  end

  def editable?
    false
  end
  helper_method :editable?

  def answer_params
    params.permit(answers: {})[:answers] || {}
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

  def payment_link_url
    ENV['PAYMENT_LINK'] + show_reference_number
  end
  helper_method :payment_link_url

  def delete_session
    flash[:confirmation] = 'Session will expired'
  end

  def destroy_session
    flash[:session_destroyed] = 'Session removed'
  end

  def redirect_to_expired_page
    redirect_to '/session/expired'
  end

  def session_expiry_time
    session[:expires_at]
  end
  helper_method :session_expiry_time

  # DEPRECATED - remove once all references to in_progress? changed to allowed_page?
  def in_progress?
    allowed_page?
  end
  helper_method :in_progress?

  def allowed_page?
    request.path == root_path ||
      request.path.include?('return') ||
      allowed_pages.include?(strip_url(request.path))
  end
  helper_method :allowed_page?

  def allowed_pages
    urls = service.standalone_pages.map do |page|
      strip_url(page.url)
    end
    urls << 'session/expired'
  end

  def strip_url(url)
    url.to_s.chomp('/').reverse.chomp('/').reverse
  end

  def save_and_return_enabled?
    ENV['SAVE_AND_RETURN'].present?
  end
  helper_method :save_and_return_enabled?

  def service_slug_config
    ENV['SERVICE_SLUG']
  end

  def editor_preview?
    false
  end
  helper_method :editor_preview?

  def confirmation_email_enabled?
    ENV['CONFIRMATION_EMAIL_COMPONENT_ID'].present?
  end
  helper_method :confirmation_email_enabled?

  def confirmation_email
    load_user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']] if confirmation_email_enabled?
  end
  helper_method :confirmation_email

  def is_confirmation_email_question?(component_id)
    ENV['CONFIRMATION_EMAIL_COMPONENT_ID'] == component_id if confirmation_email_enabled?
  end
  helper_method :is_confirmation_email_question?

  def first_page?
    if @page.present?
      @page.url == service.pages[1].url
    else
      false
    end
  end
  helper_method :first_page?

  def use_external_start_page?
    ENV['EXTERNAL_START_PAGE_URL'].present?
  end
  helper_method :use_external_start_page?

  def external_start_page_url
    if ENV['EXTERNAL_START_PAGE_URL'].blank?
      ''
    else
      # ensure url is absolute - we limit to only gov.uk urls which will be https
      unless ENV['EXTERNAL_START_PAGE_URL'][/\Ahttps:\/\//]
        return "https://#{ENV['EXTERNAL_START_PAGE_URL']}"
      end

      ENV['EXTERNAL_START_PAGE_URL']
    end
  end
  helper_method :external_start_page_url

  def start_page_url
    external_start_page_url.empty? ? root_path : external_start_page_url
  end
  helper_method :start_page_url
end
