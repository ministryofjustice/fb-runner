class HomeController < ApplicationController
  def show
    render inline: Page.new(path: '../fb-ioj/metadata/page/page.start.json').render
  end
end
