module Platform
  class SubmitterPayload
    include Platform::Connection
    attr_reader :service, :user_data, :session

    CSV = 'csv'.freeze
    EMAIL = 'email'.freeze

    def initialize(service:, user_data:, session:)
      @service = service
      @user_data = user_data
      @session = session
    end

    def to_h
      {
        meta: meta,
        service: service_info,
        actions: actions,
        pages: pages,
        attachments: attachments
      }
    end

    def service_info
      {
        id: service.service_id,
        slug: service.service_slug,
        name: service.service_name
      }
    end

    def concatenation_with_reference_number(text)
      text.gsub('{{reference_number}}', user_data['moj_forms_reference_number'] || '')
    end

    def meta
      {
        pdf_heading: concatenation_with_reference_number(ENV['SERVICE_EMAIL_PDF_HEADING']),
        pdf_subheading: ENV['SERVICE_EMAIL_PDF_SUBHEADING'].to_s,
        submission_at: Time.zone.now.iso8601,
        reference_number: user_data['moj_forms_reference_number']
      }.compact
    end

    def actions
      [email_action, csv_action, confirmation_email_action].compact
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
      answer = page_answers.send(component.id)

      if self.class.private_method_defined?(component.type.to_sym)
        send(component.type.to_sym, answer)
      else
        answer&.strip
      end
    end

    def heading(page)
      page.type == 'page.multiplequestions' ? page.heading : ''
    end

    def attachments
      answered_upload_components.map do |component|
        {
          url: file_download_url(component['fingerprint']),
          filename: component['original_filename'],
          mimetype: component['type'] || component['content_type']
        }
      end
    end

    private

    def email_action
      return if ENV['SERVICE_EMAIL_OUTPUT'].blank?

      {
        kind: EMAIL,
        to: ENV['SERVICE_EMAIL_OUTPUT'],
        from: ENV['SERVICE_EMAIL_FROM'],
        subject: concatenation_with_reference_number(ENV['SERVICE_EMAIL_SUBJECT']),
        email_body: concatenation_with_reference_number(ENV['SERVICE_EMAIL_BODY']),
        include_attachments: true,
        include_pdf: true
      }
    end

    def csv_action
      return if ENV['SERVICE_EMAIL_OUTPUT'].blank? || ENV['SERVICE_CSV_OUTPUT'].blank?

      {
        kind: CSV,
        to: ENV['SERVICE_EMAIL_OUTPUT'],
        from: ENV['SERVICE_EMAIL_FROM'],
        subject: "CSV - #{concatenation_with_reference_number(ENV['SERVICE_EMAIL_SUBJECT'])}",
        email_body: '',
        include_attachments: true,
        include_pdf: false
      }
    end

    def confirmation_email_action
      return if confirmation_email_answer.blank?

      {
        kind: EMAIL,
        to: confirmation_email_answer,
        from: ENV['SERVICE_EMAIL_FROM'],
        subject: concatenation_with_reference_number(ENV['CONFIRMATION_EMAIL_SUBJECT']),
        email_body: inject_reference_payment_content(ENV['CONFIRMATION_EMAIL_BODY']),
        include_attachments: true,
        include_pdf: true
      }
    end

    def strip_content_components(components)
      return [] if components.blank?

      components.reject(&:content?)
    end

    def answered_upload_components
      upload_components.map { |component| user_data[component.id] }.compact.reject(&:blank?)
    end

    def upload_components
      components = service.pages.map do |page|
        page.components&.select(&:upload?)
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

    def checkboxes(answer)
      answer.to_a.join('; ')
    end

    def upload(answer)
      answer['original_filename'] || ''
    end

    def autocomplete(answer)
      return '' if answer.blank?

      JSON.parse(answer)['value']
    end

    def confirmation_email_answer
      @confirmation_email_answer ||= user_data[ENV['CONFIRMATION_EMAIL_COMPONENT_ID']]
    end

    def inject_reference_payment_content(text)
      concatenation_with_reference_number(text).gsub('{{payment_link}}', payment_reference)
    end

    def payment_reference
      "#{ENV['PAYMENT_LINK']}#{user_data['moj_forms_reference_number']}"
    end
  end
end
