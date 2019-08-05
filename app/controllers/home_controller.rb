class HomeController < ApplicationController
  def show
    @service = Service.new(path: '../fb-ioj', config: { csrf: form_authenticity_token })
    @page = @service.find_page_for_url(request.path)

    render inline: @page.render
  end

  def handle_post
    @service = Service.new(path: '../fb-ioj', config: { csrf: form_authenticity_token })
    @page = @service.find_page_for_url(request.path)

    @flow = Flow.new(service: @service, page: @page)
    redirect_to("#{@flow.next_page.url}")
  end
end
