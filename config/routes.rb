Rails.application.routes.draw do
  scope "(:locale)", :locale => /en|uk/ do # at the beginning

    devise_for :users

    get 'films/search', to: 'films#search'

    # Creates set of REST routes
    resources :films

  end
  get '/:locale' => 'films#index'

  # Set root URL
  root :to => 'films#index'
end
