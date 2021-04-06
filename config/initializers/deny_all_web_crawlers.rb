Rails.application.config.deny_all_web_crawlers = ActiveModel::Type::Boolean.new.cast(ENV.fetch('DENY_ALL_WEB_CRAWLERS', true))
