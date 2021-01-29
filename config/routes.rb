Rails.application.routes.draw do
  get '/health', to: 'health#show'

  mount MetadataPresenter::Engine => "/"
end
