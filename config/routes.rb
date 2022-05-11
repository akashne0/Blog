Rails.application.routes.draw do
  #admin_page
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  #devise login
  devise_for :users, controllers: {
    confirmations: 'confirmations'
  }
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
  
  root 'articles#index'
  get 'about', to: 'pages#about'
  
  delete 'articles/:id/delete' => 'articles#destroy', as: 'articles_delete'
  get '/articles/:id/delete' => 'articles#destroy'
  resources :articles,  except: [:destroy]  do
    member do
      patch :upvote
      patch :downvote
      # get "like", to: "articles#upvote", :defaults => { :format => 'js' }
      # get "unlike", to: "articles#downvote", :defaults => { :format => 'js'}
    end
    resources :comments
  end
  
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
