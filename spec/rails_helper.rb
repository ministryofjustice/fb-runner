# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
ENV['SERVICE_FIXTURE'] ||= 'version'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
Bundler.require(:development, :test)
Dir.glob("#{Rails.root}/spec/support/*/**/*.rb").sort.each { |f| require f }
require 'metadata_presenter/test_helpers'

RSpec.configure do |config|
  config.use_active_record = false

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
  config.include FeatureSteps
  config.include TestHelper

  config.before do |example_group|
    if example_group.metadata[:type] && example_group.metadata[:type].to_sym.equal?(:feature)
      WebMock.allow_net_connect!
    end
  end

  config.after do |example_group|
    if example_group.metadata[:type] && example_group.metadata[:type].to_sym.equal?(:feature)
      WebMock.disable_net_connect!

      if example_group.exception.present?
        puts '======================================='
        puts form.text
        puts '======================================='
      end
    end
  end

  config.include MetadataPresenter::TestHelpers
end
