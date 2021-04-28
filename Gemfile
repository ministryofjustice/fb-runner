source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'faraday'
gem 'faraday_middleware'
gem 'jwt'
# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#     github: 'ministryofjustice/fb-metadata-presenter',
#     branch: 'submissions-v2'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
#
gem 'fb-jwt-auth', '0.6.0'
gem 'metadata_presenter', '1.0.3'
gem 'prometheus-client', '~> 2.1.0'
gem 'puma', '~> 5.2'
gem 'rails', '~> 6.1.3'
gem 'sass-rails', '>= 6'
gem 'sentry-rails', '~> 4.3.4'
gem 'sentry-ruby', '~> 4.3.2'
gem 'webpacker', '~> 5.3'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'site_prism'
  gem 'webmock'
end

group :development do
  gem 'dotenv-rails'
  gem 'listen', '~> 3.5'
  gem 'rubocop', '~> 1.10.0'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
