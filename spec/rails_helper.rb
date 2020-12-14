# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
Bundler.require(:development, :test)
Dir.glob("#{Rails.root}/spec/support/*/**/*.rb").sort.each { |f| require f }

RSpec.configure do |config|
  config.use_active_record = false

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
  config.include FeatureSteps

  config.after do |example_group|
    if example_group.exception.present? &&
        example_group.metadata[:type].to_sym.equal?(:feature)
      puts '======================================='
      puts form.text
      puts '======================================='
    end
  end
end
