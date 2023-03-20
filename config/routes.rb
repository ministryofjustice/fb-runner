Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/robots.txt', to: 'robots_txts#show'

  get '/session/remaining', to: 'session#remaining'
  get 'session/extend', to: 'session#extend'
  get 'session/reset', to: 'session#reset'

  mount MetadataPresenter::Engine => "/"
end
