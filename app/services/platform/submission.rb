module Platform
  class Submission
    include ActiveModel::Model
    attr_accessor :service, :user_data

    REQUIRED_ENV_VARS = %w(SERVICE_EMAIL_OUTPUT).freeze

    validate do
      if REQUIRED_ENV_VARS.any? { |env_var| ENV[env_var].blank? }
        self.errors.add(:base, "#{REQUIRED_ENV_VARS} env vars are blank.")
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
