class HealthController < ActionController::API
  def show
    Rails.logger.silence do
      render plain: 'healthy'
    end
  end
end
