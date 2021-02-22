Rails.application.reloader.to_prepare do
  ActiveSupport::Notifications.subscribe(
    Platform::SubmitterAdapter::SUBSCRIPTION
  ) do |name, starts, ends, _, env|
    url = env[:url]
    http_method = env[:method].to_s.upcase
    duration = ends - starts
    response_status = env[:status]

    if Rails.env.production?
      Rails.logger.info(
        'Submitter API request: [%s] %s (%.3f s). Response status: %s' % [
          url.host, http_method, duration, response_status
        ]
      )
    else
      Rails.logger.info(
        'Submitter API request: [%s] %s %s (%.3f s)' % [
          url.host,
          http_method,
          env[:url].to_s,
          duration
        ]
      )
      Rails.logger.info('Request Headers: %s' % [env[:request_headers]])
      Rails.logger.info('Request Body: %s' % [env[:request_body]])
      Rails.logger.info('Response Body: %s' % [env[:response_body]])
      Rails.logger.info('Response Status: %s' % [response_status])
    end
  end
end
