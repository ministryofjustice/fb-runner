class ServiceController < ApplicationController
  def start
    @service = Service.new
    @start_page = @service.pages.first
  end
end
