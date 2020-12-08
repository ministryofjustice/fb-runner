ActiveSupport::Notifications.subscribe(UserDatastoreAdapter::SUBSCRIPTION) do |name, starts, ends, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = ends - starts
  Rails.logger.info('Datastore request: [%s] %s (%.3f s)' % [url.host, http_method, duration])
end
