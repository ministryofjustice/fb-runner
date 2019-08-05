Rails.application.routes.draw do
  root 'home#handle_get'

  get '*path', to: 'home#handle_get'
  post '*path', to: 'home#handle_post'
end
