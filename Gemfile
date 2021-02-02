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
#     branch: 'some-branch'
#gem 'metadata_presenter', path: '../fb-metadata-presenter'
#
gem 'metadata_presenter', '0.3.2'
gem 'puma', '~> 5.2'
gem 'rails', '~> 6.1.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.2'
gem 'fb-jwt-auth', '0.5.0'

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'webmock'
  gem 'simplecov'
  gem 'capybara'
  gem 'site_prism'
  gem 'simplecov-console'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.4'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
