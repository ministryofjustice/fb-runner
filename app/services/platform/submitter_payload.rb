module Platform
  class SubmitterPayload
    include Platform::Connection
    include ConfirmationEmailHelper
    attr_reader :service, :user_data, :session

    CSV = 'csv'.freeze
    EMAIL = 'email'.freeze
    SUBMISSION_EMAIL = 'submission'.freeze
    CONFIRMATION_EMAIL = 'confirmation'.freeze
    DEFAULT_EMAIL_ADDRESS = 'no-reply-moj-forms@digital.justice.gov.uk'.freeze

    def initialize(service:, user_data:, session:)
      @service = service
      @user_data = user_data
      @session = session
    end

    def to_h
      {
        meta:,
        service: service_info,
        actions:,
        pages:,
        attachments:
      }
    end

    def service_info
      {
        id: service.service_id,
        slug: ENV['SERVICE_SLUG'],
        name: service.service_name
      }
    end

    def concatenation_with_reference_number(text)
      text.gsub('{{reference_number}}', user_data['moj_forms_reference_number'] || '')
    end

    def meta
      if ENV['SERVICE_EMAIL_OUTPUT'].blank?
        {
          pdf_heading: "JSON Submission for #{service.service_name}",
          pdf_subheading: '',
          submission_at: Time.zone.now.iso8601
        }.compact
      else
        {
          pdf_heading: concatenation_with_reference_number(ENV['SERVICE_EMAIL_PDF_HEADING']),
          pdf_subheading: ENV['SERVICE_EMAIL_PDF_SUBHEADING'].to_s,
          submission_at: Time.zone.now.iso8601,
          reference_number: user_data['moj_forms_reference_number']
        }.compact
      end
    end

    def actions
      [email_action, csv_action, confirmation_email_action, json_action, ms_list_action].compact
    end

    def pages
      answered_pages.map { |page|
        components = strip_content_components(page.components)
        next if components.empty?

        {
          heading: heading(page),
          answers: components.map do |component|
            {
              field_id: component.id,
              field_name: component.humanised_title,
              answer: answer_for(page, component)
            }
          end
        }
      }.compact
    end

    def answered_pages
      MetadataPresenter::TraversedPages.new(service, user_data).all
    end

    def answer_for(page, component)
      page_answers = MetadataPresenter::PageAnswers.new(page, user_data)

      component_type = component.type
      component_id = component.id

      answer = page_answers.send(component_id)

      return answer&.strip unless self.class.private_method_defined?(component_type)

      begin
        # For component types like `date`, `checkboxes`, etc.
        # we call private methods having the same name as the type
        send(component_type, answer)
      rescue StandardError
        Sentry.configure_scope do |scope|
          scope.set_context('answer_for', { component_type:, component_id:, answer: answer.inspect })
        end

        raise # re-raise the exception
      end
    end

    def heading(page)
      page.type == 'page.multiplequestions' ? page.heading : ''
    end

    def attachments
      multiupload_attachments = answered_multiupload_components.map do |component|
        Rails.logger.info(component)
        component.map do |file|
          Rails.logger.info(file)
          return nil if file['original_filename'].blank?

          {
            url: file_download_url(file['fingerprint']),
            filename: file['original_filename'],
            mimetype: file['type'] || file['content_type']
          }
        end
      end

      single_upload_attachments = answered_upload_components.map do |component|
        Rails.logger.info(component)
        {
          url: file_download_url(component['fingerprint']),
          filename: component['original_filename'],
          mimetype: component['type'] || component['content_type']
        }
      end

      multiupload_attachments.flatten.reject { |f| f[:filename].blank? }.concat(single_upload_attachments).flatten
    end

    private

    def email_action
      return if ENV['SERVICE_EMAIL_OUTPUT'].blank?

      {
        kind: EMAIL,
        variant: SUBMISSION_EMAIL,
        to: ENV['SERVICE_EMAIL_OUTPUT'],
        from: default_email_from,
        subject: concatenation_with_reference_number(ENV['SERVICE_EMAIL_SUBJECT']),
        email_body: concatenation_with_reference_number(ENV['SERVICE_EMAIL_BODY']),
        user_answers: answers_html(pages, heading: false),
        include_attachments: true,
        include_pdf: true
      }
    end

    def csv_action
      return if ENV['SERVICE_EMAIL_OUTPUT'].blank? || ENV['SERVICE_CSV_OUTPUT'].blank?

      {
        kind: CSV,
        to: ENV['SERVICE_EMAIL_OUTPUT'],
        from: default_email_from,
        subject: "CSV - #{concatenation_with_reference_number(ENV['SERVICE_EMAIL_SUBJECT'])}",
        email_body: '',
        user_answers: '',
        include_attachments: true,
        include_pdf: false
      }
    end

    def confirmation_email_action
      return if confirmation_email_answer.blank?

      {
        kind: EMAIL,
        variant: CONFIRMATION_EMAIL,
        to: confirmation_email_answer,
        from: confirmation_email_reply_to,
        subject: concatenation_with_reference_number(ENV['CONFIRMATION_EMAIL_SUBJECT']),
        email_body: inject_reference_payment_content(ENV['CONFIRMATION_EMAIL_BODY']),
        user_answers: answers_html(pages, heading: true),
        include_attachments: false,
        include_pdf: false
      }
    end

    def strip_content_components(components)
      return [] if components.blank?

      components.reject(&:content?)
    end

    def answered_upload_components
      upload_components.map { |component| user_data[component.id] }.compact.reject(&:blank?)
    end

    def answered_multiupload_components
      multiupload_components.map { |component| user_data[component.id] }.compact.reject { |c| c.all?(&:blank?) }
    end

    def upload_components
      components = service.pages.map do |page|
        page.components&.select(&:upload?)
      end
      components.flatten.compact
    end

    def multiupload_components
      components = service.pages.map do |page|
        page.components&.select(&:multiupload?)
      end
      components.flatten.compact
    end

    def file_download_url(fingerprint)
      "#{ENV['USER_FILESTORE_URL']}" \
      "/service/#{ENV['SERVICE_SLUG']}" \
      "/user/#{user_id}" \
      "/#{fingerprint}"
    end

    def date(answer)
      return '' if answer.blank?

      I18n.l(
        Date.civil(answer.year.to_i, answer.month.to_i, answer.day.to_i),
        format: '%d %B %Y'
      )
    end

    def address(answer)
      answer.as_json
    end

    def checkboxes(answer)
      answer.to_a.join('; ')
    end

    def upload(answer)
      answer['original_filename'] || ''
    end

    def multiupload(answer)
      return '' if answer.nil?

      answer.values.first.map { |i| i['original_filename'] }.join('; ')
    end

    def autocomplete(answer)
      return '' if answer.blank?

      JSON.parse(answer)['value']
    end

    def confirmation_email_answer
      @confirmation_email_answer ||= confirmation_email if user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']].present?
    end

    def inject_reference_payment_content(text)
      concatenation_with_reference_number(text).gsub('{{payment_link}}', payment_reference)
    end

    def payment_reference
      "#{ENV['PAYMENT_LINK']}#{user_data['moj_forms_reference_number']}"
    end

    def confirmation_email
      if user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']] == ENV['SERVICE_EMAIL_OUTPUT']
        user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']].gsub('@', '+confirmation@')
      else
        user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']]
      end
    end

    def confirmation_email_from_address
      @confirmation_email_from_address ||= ENV['CONFIRMATION_EMAIL_REPLY_TO'].presence || ENV['SERVICE_EMAIL_FROM']
    end

    def service_name
      @service_name ||= service.service_name
    end

    def confirmation_email_reply_to
      @confirmation_email_reply_to ||= "#{service_name} <#{confirmation_email_from_address}>"
    end

    def default_email_from
      @default_email_from ||= "#{service_name} <#{DEFAULT_EMAIL_ADDRESS}>"
    end

    def json_action
      return if ENV['SERVICE_OUTPUT_JSON_ENDPOINT'].blank? || ENV['SERVICE_OUTPUT_JSON_KEY'].blank?

      {
        kind: 'json',
        url: ENV['SERVICE_OUTPUT_JSON_ENDPOINT'],
        key: ENV['SERVICE_OUTPUT_JSON_KEY'],
        include_attachments: true
      }
    end

    def ms_list_action
      return if ENV['MS_SITE_ID'].blank? || ENV['MS_LIST_ID'].blank?

      {
        kind: 'mslist',
        graph_url: ENV['MS_GRAPH_ROOT_URL'] || 'https://graph.microsoft.com/v1.0/',
        site_id: ENV['MS_SITE_ID'],
        list_id: ENV['MS_LIST_ID'],
        drive_id: ENV['MS_DRIVE_ID'],
        include_attachments: send_attachments_to_ms_list?
      }
    end

    def send_attachments_to_ms_list?
      ENV['MS_DRIVE_ID'].present? && attachments.count.positive?
    end
  end
end
