source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#     github: 'ministryofjustice/fb-metadata-presenter',
#     branch: 'update-govuk-crest'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
gem 'metadata_presenter', '3.4.13'

gem 'aws-sdk-s3'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'faraday'
gem 'faraday_middleware'
gem 'fb-jwt-auth', '0.10.0'
gem 'jwt'
gem 'prometheus-client', '~> 4.2.0'
gem 'puma', '~> 6.4'
gem 'rack', '~> 2.2.23'
gem 'rails', '~> 7.2.3.1'
gem 'sass-rails', '>= 6'
gem 'sentry-rails', '~> 5.20'
gem 'sentry-ruby', '~> 5.20'
gem 'webpacker', '~> 5.4'

group :development, :test do
  gem 'brakeman'
  gem 'byebug'
  gem 'capybara'
  gem 'dotenv-rails', '~> 3.1.3'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 7.0.2'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'site_prism', '~> 5.0'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.8'
  gem 'rubocop', '~> 1.59'
  gem 'rubocop-govuk', '~> 4.13.0'
  gem 'spring', '~> 4.1.1'
  gem 'spring-watcher-listen', '~> 2.1.0'
  gem 'web-console', '>= 3.3.0'
end
