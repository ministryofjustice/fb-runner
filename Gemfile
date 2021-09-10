source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'faraday'
gem 'faraday_middleware'
gem 'jwt'
# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
# gem 'metadata_presenter',
#    github: 'ministryofjustice/fb-metadata-presenter',
#    branch: 'change-your-answers'
# gem 'metadata_presenter', path: '../fb-metadata-presenter'
#
gem 'fb-jwt-auth', '0.7.0'
gem 'metadata_presenter', '2.4.1'
gem 'prometheus-client', '~> 2.1.0'
gem 'puma', '~> 5.4'
gem 'rails', '~> 6.1.4'
gem 'sass-rails', '>= 6'
gem 'sentry-rails', '~> 4.7.2'
gem 'sentry-ruby', '~> 4.7.1'
gem 'webpacker', '~> 5.4'

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
  gem 'listen', '~> 3.7'
  gem 'rubocop', '~> 1.15.0'
  gem 'rubocop-govuk'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
