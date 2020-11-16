Rails.application.routes.draw do
  # root to: 'service#start'
  mount Fb::Metadata::Presenter::Engine => "/"
end
