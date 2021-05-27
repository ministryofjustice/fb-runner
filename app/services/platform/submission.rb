module Platform
  class MissingSubmitterUrlError < StandardError
  end

  class Submission
    include ActiveModel::Model
    attr_accessor :service, :user_data, :session

    REQUIRED_ENV_VARS = %w[SERVICE_EMAIL_OUTPUT SUBMITTER_URL].freeze

    validate do
      if REQUIRED_ENV_VARS.any? { |env_var| ENV[env_var].blank? }
        errors.add(:base, "#{REQUIRED_ENV_VARS} env vars are blank.")
      end
    end

    def save
      raise MissingSubmitterUrlError if ENV['SUBMITTER_URL'].blank? && Rails.env.production?

      invalid? || Platform::SubmitterAdapter.new(service_slug: service.service_slug, payload: submitter_payload).save
    end

    def submitter_payload
      Platform::SubmitterPayload.new(
        service: service,
        user_data: user_data,
        session: session
      ).to_h
    end
  end
end
