module Platform
  class MissingSubmitterUrlError < StandardError
  end

  class Submission
    include ActiveModel::Model
    attr_accessor :service, :user_data, :session

    REQUIRED_ENV_VARS = %w[SUBMITTER_URL].freeze

    validate do
      if ENV['SERVICE_EMAIL_OUTPUT'].blank? && ENV['SERVICE_OUTPUT_JSON_ENDPOINT'].blank? && ENV['CONFIRMATION_EMAIL_COMPONENT_ID'].blank?
        errors.add(:base, 'SERVICE_EMAIL_OUTPUT env vars are blank.')
      end

      if REQUIRED_ENV_VARS.any? { |env_var| ENV[env_var].blank? }
        errors.add(:base, "#{REQUIRED_ENV_VARS} env vars are blank.")
      end
    end

    def save
      raise MissingSubmitterUrlError if ENV['SUBMITTER_URL'].blank? && Rails.env.production?

      invalid? || adapter.save
    end

    def adapter
      Platform::SubmitterAdapter.new(
        session:,
        service_slug: ENV['SERVICE_SLUG'],
        payload: submitter_payload
      )
    end

    def submitter_payload
      Platform::SubmitterPayload.new(
        service:,
        user_data:,
        session:
      ).to_h
    end
  end
end
