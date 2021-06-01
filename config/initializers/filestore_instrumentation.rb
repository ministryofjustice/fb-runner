Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe(
    Platform::UserFilestoreAdapter::SUBSCRIPTION
  ) do |name, starts, ends, _, env|
    url = env[:url]
    http_method = env[:method].to_s.upcase
    duration = ends - starts
    response_status = env[:status]

    if Rails.env.production?
      Rails.logger.info(
        'Filestore API request: [%s] %s (%.3f s). Response status: %s' % [
          url.host,
          http_method,
          duration,
          response_status
        ]
      )
    else
      Rails.logger.info(
        'Filestore API request: [%s] %s %s (%.3f s). Request Headers %s. Response Body: %s. Response status: %s' % [
          url.host,
          http_method,
          env[:url].to_s,
          duration,
          env[:request_headers],
          env[:response_body],
          response_status
        ]
      )
    end
  end
end
