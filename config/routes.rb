Rails.application.routes.draw do
  get '/', to: 'home#handle_get'
  post '/', to: 'home#handle_post'

  get '*path', to: 'home#handle_get'
  post '*path', to: 'home#handle_post'
end
