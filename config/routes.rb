Rails.application.routes.draw do
  root 'home#show'

  post '/', to: 'home#handle_post'
end
