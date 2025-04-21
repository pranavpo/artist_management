Rails.application.routes.draw do
  get "songs/create"
  get "songs/update"
  get "songs/destroy"
  get "songs/show"
  get "songs/index"
  get "auth/login"
  # Authentication routes
  post '/login', to: 'auth#login'
  # RESTful user routes (create, update, destroy)
  resources :users, only: [:create, :update, :destroy]
  get '/users', to: 'users#get_all_users'
  get '/artists', to: 'users#get_all_artists'
  get '/artist-managers', to: 'users#get_all_artist_managers'
  get '/users/:id', to: 'users#show', defaults: { format: :json }
  # get '/users/:id', to: 'users#show'
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  # root "posts#index"
  resources :artists, only: [] do
    resources :songs, only: [:index, :create]
  end
  
  resources :songs, only: [:show, :update, :destroy]
end
