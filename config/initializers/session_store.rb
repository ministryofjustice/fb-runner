Rails.application.config.session_store :cookie_store,
  expire_after: ENV.fetch('SESSION_DURATION', 30).to_i.minutes,
  key: '_fb_runner_session'
