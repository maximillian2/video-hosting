Rails.application.routes.draw do
  get 'welcome/index'

  scope '(:locale)', :locale => /en|uk/ do # at the beginning

    devise_for :users

    # Creates set of REST routes
    resources :films do
      get 'search', on: :collection
    end

  end
  get '/:locale' => 'films#index'

  # Set root URL
  root :to => 'welcome#index'
end
