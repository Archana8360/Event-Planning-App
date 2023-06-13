Rails.application.routes.draw do
  
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    confirmations: 'users/confirmations' ,
    registrations: 'users/registrations'
  }

  # post '/users/confirmations', to: 'users/confirmations#create', as: 'confirm_user_account'
  post '/report', to: 'events#report'
  
  get '/sort_events/start_date', to: 'events#sort_events'
  get '/sort_events/start_time', to: 'events#sort_events'

  get '/search_events', to: 'events#search_events'
 
  post '/mark_favourite', to: 'events#mark_favourite'
  post '/join_event', to: 'events#join_event'
  post '/follow_user', to: 'events#follow_user'
  post '/like_event', to: 'events#like_event'


  post 'users/forgot_passwrd', to: 'password_reset#send_otp'
  post 'users/verify_otp', to: 'password_reset#verify_otp'
  post 'users/reset_password', to: 'password_reset#reset_password' 


  post 'events/' ,to: 'events#create'
  get 'events',to: 'events#index'
  put 'events/:id/' ,to:'events#update'
  delete 'events/:id/' ,to:'events#destroy' 
  get '/user_events', to: 'events#show_all' 
  get '/favourite_events', to: 'events#favorite_events'
  get '/event_categories', to: 'events#event_categories'
  get '/events_nearby', to: 'events#events_nearby'
  get '/events_details/:id', to: 'events#events_details'
  get '/user_details/:id', to: 'events#user_details'
  get '/search_events/:search_by', to: 'events#search_events'


  get '/sort_events', to: 'events#sort_events'


  post '/profile', to: 'profiles#create'
  put '/update_profile', to: 'profiles#update'
  get '/user_profile', to: 'profiles#show'
  delete '/profile', to: 'profiles#destroy'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  #Admin Panel Routes
  devise_scope :user do
    authenticated :user do
      root 'admin/home#dashboard', as: :authenticated_root
    end
  
    unauthenticated do
      root 'admin/auth/sessions#new', as: :unauthenticated_root
    end
  end

  namespace :admin do
    get 'login', to: 'auth/sessions#new', as: :login
    post 'login', to: 'auth/sessions#create', as: :post_login
    delete 'logout', to: 'auth/sessions#destroy', as: :logout
    get '/profile', to: 'home#profile', as: :profile
    patch '/profile', to: 'home#update_profile', as: :update_profile
    post '/settings', to: 'home#update_settings', as: :update_settings
    get 'forgot-password', to: 'auth/passwords#new', as: :forgot_password
    post 'forgot/send_mail',to: "auth/passwords#passwordreset", as: :send_reset_instructions
    get 'reports', to: "reports#index" ,as: :reports
    patch 'reports/update_status/:id', to: "reports#update_status" 
    patch 'reports/disapprove/:id', to: "reports#disapprove",as: :reports_disapprove
    get 'reports/:id', to: "reports#show" ,as: :report
    patch "/reports/:id", to:"reports#update",as: :report_update
    patch "/users/:id", to:"users#update",as: :user_update
    get '/settings', to: 'home#settings', as: :settings
    
    resources :hashtags do
      member do
        patch 'update_status'
      end
    end
    resources :users, except: [:new, :create,:edit,:update] do
      member do
        patch 'update_status'
      end
    end
    resources :events, except: [:new, :create,:edit,:update] do
      member do
        patch 'update_status'
      end
    end
    patch "/events/:id", to:"events#update",as: :event_update

    resources :event_categories do
      member do
        patch 'update_status'
      end
    end
  end

  
end
