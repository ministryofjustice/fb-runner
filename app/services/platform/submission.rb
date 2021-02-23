module Platform
  class Submission
    include ActiveModel::Model
    attr_accessor :service, :user_data

    REQUIRED_ENV_VARS = %w(
      SERVICE_EMAIL_PDF_HEADING
      SERVICE_EMAIL_PDF_SUBHEADING
      SERVICE_EMAIL_OUTPUT
      SERVICE_EMAIL_SENDER
      SERVICE_EMAIL_SUBJECT
      SERVICE_EMAIL_BODY
    ).freeze

    validate do
      if REQUIRED_ENV_VARS.any? { |env_var| ENV[env_var].blank? }
        Rails.logger.info(
          'Ignoring submission. There are env vars missing: %{env_vars}' % {
            env_vars: REQUIRED_ENV_VARS.select { |env_var| ENV[env_var].blank? }
          }
        )
        self.errors.add(:base)
      end
    end

    def save
      invalid? || Platform::SubmitterAdapter.new(payload: submitter_payload).save
    end

    def submitter_payload
      Platform::SubmitterPayload.new(
        service: service,
        user_data: user_data
      ).to_h
    end
  end
end
