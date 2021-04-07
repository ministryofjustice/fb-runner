module Rack
  class XRobotsTag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      if Rails.application.config.deny_all_web_crawlers
        headers['X-Robots-Tag'] = 'none'
      end

      [status, headers, response]
    end
  end
end
