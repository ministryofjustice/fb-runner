module Platform
  class MissingSubmitterUrlError < StandardError
  end

  class Submission
    include ActiveModel::Model
    attr_accessor :service, :user_data, :session

    REQUIRED_ENV_VARS = %w[SUBMITTER_URL].freeze

    validate do
      if ENV['SERVICE_EMAIL_OUTPUT'].blank? && ENV['SERVICE_OUTPUT_JSON_ENDPOINT'].blank?
        errors.add(:base, 'SERVICE_EMAIL_OUTPUT env vars are blank.')
      end

      if REQUIRED_ENV_VARS.any? { |env_var| ENV[env_var].blank? }
        errors.add(:base, "#{REQUIRED_ENV_VARS} env vars are blank.")
      end
    end

    def save
      raise MissingSubmitterUrlError if ENV['SUBMITTER_URL'].blank? && Rails.env.production?

      Rails.logger.debug '*********** No submitter error'
      invalid? || adapter.save
    end

    def adapter
      Rails.logger.debug '*********** New submitter adapter'
      Platform::SubmitterAdapter.new(
        session:,
        service_slug: service.service_slug,
        payload: submitter_payload
      )
    end

    def submitter_payload
      Rails.logger.debug '*************** New submitter payload'
      Platform::SubmitterPayload.new(
        service:,
        user_data:,
        session:
      ).to_h
    end
  end
end
