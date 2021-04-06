Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/robots.txt', to: 'robots_txts#show'

  mount MetadataPresenter::Engine => "/"
end
