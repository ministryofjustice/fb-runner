EXCLUDE_PATHS = %w[/health /robots.txt].freeze

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.logger =  Logger.new(STDOUT)

  config.traces_sampler = lambda do |sampling_context|
    transaction_context = sampling_context[:transaction_context]
    transaction_name = transaction_context[:name]

    !transaction_name.in?(EXCLUDE_PATHS)
  end

  config.before_send = lambda do |event, _hint|
    if event.request && event.request.data
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      event.request.data = filter.filter(event.request.data)
    end
    event
  end
end
