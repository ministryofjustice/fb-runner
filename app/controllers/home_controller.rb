class HomeController < ApplicationController
  def show
    render inline: Page.new(path: '../fb-ioj/metadata/page/page.start.json', config: { csrf: form_authenticity_token }).render
  end

  def handle_post
    render inline: 'handle post here'
    # determine where should i go to
    # redirect user
  end
end
