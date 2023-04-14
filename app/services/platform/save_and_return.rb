module Platform
  class MissingSubmitterUrlError < StandardError
  end

  class SaveAndReturn
    include ActiveModel::Model
    attr_accessor :service, :user_data, :session

    REQUIRED_ENV_VARS = %w[SAVE_AND_RETURN_EMAIL SUBMITTER_URL].freeze

    validate do
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
        service_slug: service.service_slug,
        payload: save_and_return_payload
      )
    end

    def save_and_return_payload
      Platform::SaveAndReturnPayload.new(
        service:,
        user_data:,
        session:
      ).to_h
    end
  end
end
