# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src  :self,
                       "https://*.googletagmanager.com",
                       "https://*.google-analytics.com",
                       "'sha256-/00WcN7mhsXVmNcOlHH44RbwXUP6oVtwcewj3ZTEcxY='",
                       "'sha256-6vsluniIV9AVB77S6y438x5foeFJFuwLLypiwVzYNbw='"
    policy.style_src   :self, :https

    # Specify URI for violation reports
    #  Currently disabled to prevent sentry overload
      # policy.report_uri "report-uri #{ENV['SENTRY_CSP_URL']}"
  end
#
#   # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session[:session_id] }
  config.content_security_policy_nonce_directives = %w(script-src)
#
#   # Report violations without enforcing the policy.
    config.content_security_policy_report_only = true
end
