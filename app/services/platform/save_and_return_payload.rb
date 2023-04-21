module Platform
  class SaveAndReturnPayload
    include Platform::Connection
    attr_reader :service, :user_data, :session

    EMAIL = 'email'.freeze
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
        attachments: []
      }
    end

    def meta
      { submission_at: Time.zone.now.iso8601 }
    end

    def service_info
      {
        id: service.service_id,
        slug: service.service_slug,
        name: service.service_name
      }
    end

    def actions
      [email_action].compact
    end

    private

    def email_action
      return if email.blank?

      {
        kind: EMAIL,
        to: email,
        from: default_email_from,
        subject: default_subject,
        email_body: default_email_body,
        include_attachments: false,
        include_pdf: false
      }
    end

    def default_email_from
      @default_email_from ||= "#{service.service_name} <#{DEFAULT_EMAIL_ADDRESS}>"
    end

    def default_email_body
      @default_email_body ||= ENV['SAVE_AND_RETURN_EMAIL'].gsub('{{save_and_return_link}}', magic_link)
    end

    def default_subject
      @default_subject ||= "Resuming your application to #{service.service_name}"
    end

    def magic_link
      @magic_link ||= "https://#{service.service_slug}.form.justice.gov.uk/#{record_uuid}"
    end

    def record_uuid
      @record_uuid ||= user_data[:id]
    end

    def email
      @email ||= user_data[:email]
    end

    def pages
      @pages ||= [
        {
          heading: '',
          answers: [
            {
              field_id: 'save_and_return',
              field_name: 'Save and Return email',
              answer: email
            }
          ]
        }
      ]
    end

    def email
      @email ||= user_data['email']
    end

    def pages
      @pages ||= [
        {
          heading: '',
          answers: [
            {
              field_id: 'save_and_return',
              field_name: 'Save and Return email',
              answer: email
            }
          ]
        }
      ]
    end
  end
end
