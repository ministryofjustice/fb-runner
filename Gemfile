source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'faraday'
gem 'faraday_middleware'
gem 'jwt'
gem 'metadata_presenter', '0.1.4'
gem 'puma', '~> 5.1'
gem 'rails', '~> 6.1.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.2'

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

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
