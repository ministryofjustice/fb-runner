Rails.application.routes.draw do
  root 'home#show'

  get '*path', to: 'home#show'
  post '/', to: 'home#handle_post'
end
