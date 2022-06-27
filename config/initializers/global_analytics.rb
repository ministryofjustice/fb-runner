if ENV['PLATFORM_ENV'] == 'test' && ENV['DEPLOYMENT_ENV'] == 'dev'
  Rails.application.config.global_ga4 = 'G-H2X4P7GXNR'
end
