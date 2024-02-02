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
        slug: ENV['SERVICE_SLUG'],
        name: service_name
      }
    end

    def actions
      [email_action].compact
    end

    private

    def service_name
      service.service_name
    end

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
      @default_email_from ||= "#{service_name} <#{DEFAULT_EMAIL_ADDRESS}>"
    end

    def default_email_body
      I18n.t(
        'presenter.save_and_return.confirmation_email.body',
        service_name:, magic_link:, default: "Magic link: #{magic_link}"
      )
    end

    def default_subject
      I18n.t(
        'presenter.save_and_return.confirmation_email.subject',
        service_name:, default: "Your saved form - '#{service_name}'"
      )
    end

    def magic_link
      @magic_link ||= ENV['PLATFORM_ENV'] == 'live' ? editor_live_url : editor_test_url
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

    def editor_test_url
      ENV['DEPLOYMENT_ENV'] == 'production' ? editor_test_production_url : editor_test_dev_url
    end

    def editor_live_url
      ENV['DEPLOYMENT_ENV'] == 'production' ? editor_live_production_url : editor_live_dev_url
    end

    def editor_live_production_url
      "https://#{service_slug}.form.service.justice.gov.uk/return/#{record_uuid}".freeze
    end

    def editor_live_dev_url
      "https://#{service_slug}.dev.form.service.justice.gov.uk/return/#{record_uuid}".freeze
    end

    def editor_test_production_url
      "https://#{service_slug}.test.form.service.justice.gov.uk/return/#{record_uuid}".freeze
    end

    def editor_test_dev_url
      "https://#{service_slug}.dev.test.form.service.justice.gov.uk/return/#{record_uuid}".freeze
    end

    def service_slug
      ENV['SERVICE_SLUG']
    end
  end
end
