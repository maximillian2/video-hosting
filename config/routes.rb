Rails.application.routes.draw do
  scope "(:locale)", :locale => /en|uk/ do # at the beginning

    devise_for :users

    # Creates set of REST routes
    resources :films do
      get 'search', on: :collection
    end

  end
  get '/:locale' => 'films#index'

  # Set root URL
  root :to => 'films#index'
end
