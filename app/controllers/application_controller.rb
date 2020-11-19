class ApplicationController < ActionController::Base
	def service_metadata	
    Rails.configuration.service_metadata	
  end
end
