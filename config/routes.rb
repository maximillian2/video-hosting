Rails.application.routes.draw do

  # Creates set of REST routes
  resources :films

  # Set root URL
  root :to => 'films#index'
end
