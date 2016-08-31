Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'rooms#new'
  post '/rooms/create', to: 'rooms#create_w_moderator'
  post '/rooms/:id/show-votes', to: 'rooms#show_votes'
  post '/rooms/:id/clear-votes', to: 'rooms#clear_votes'
  post '/rooms/:id/close-voting', to: 'rooms#close_voting'
  get '/rooms/:id/state', to: 'rooms#state'
  resources :rooms, only: [:show, :update, :destroy]
  resources :users, only: [:create, :update, :destroy]
  resources :stories, only: [:destroy]
end
