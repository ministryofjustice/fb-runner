DEFAULT_SESSION_DURATION = 30
# timeout warning modal settings: https://github.com/ministryofjustice/fb-metadata-presenter/tree/main/config/initializers/session_timeout_settings.rb

Rails.application.config.session_duration = ENV.fetch('SESSION_DURATION', DEFAULT_SESSION_DURATION).to_i.minutes
Rails.application.config.session_store :cookie_store,
  expire_after: Rails.application.config.session_duration,
  key: '_fb_runner_session',
  secure: Rails.env.production?
