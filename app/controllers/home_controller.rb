class HomeController < ApplicationController
  def handle_get
    @service = Service.new(path: '../fb-ioj',
                           config: { csrf: form_authenticity_token, http_method: request.method.downcase.to_sym },
                           data: Userdata::Memory.new(session[:session_id]))

    @page = @service.find_page_for_url(request.path)

    render inline: @page.render
  end

  def handle_post
    @service = Service.new(path: '../fb-ioj',
                           config: { csrf: form_authenticity_token, http_method: request.method.downcase.to_sym },
                           data: Userdata::Memory.new(session[:session_id]))

    @page = @service.find_page_for_url(request.path)
    @page.update_userdata(params)

    if @page.valid?
      @flow = Flow.new(service: @service, page: @page)
      redirect_to("#{@flow.next_page.url}")
    else
      render inline: @page.render
    end
  end
end
