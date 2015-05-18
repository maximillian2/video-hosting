Rails.application.routes.draw do

  # Set root URL
  root :to => 'films#index'

  get 'search', to: 'films#search'

  # Creates set of REST routes
  resources :films


end
