ActiveSupport::Notifications.subscribe(UserDatastoreAdapter::SUBSCRIPTION) do |name, starts, ends, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = ends - starts
  response_status = env[:status]
  Rails.logger.info('Datastore request: [%s] %s (%.3f s). Response status: %s' % [url.host, http_method, duration, response_status])
end
