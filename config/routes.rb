Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  
  root to: "sessions#new"

  resources :users, only: [:index]

  resources :subscriptions, only: [:index, :destroy]

  resources :notifications, only: [:index, :update] do
    member do
      patch :mark_as_read
    end
  end
  
  Rails.application.routes.draw do
    resources :events do
      collection do
        get :my_events
      end
  
      member do
        post "subscribe", to: "subscriptions#create"
        delete "unsubscribe", to: "subscriptions#destroy"
        get :participants
        delete :remove_participant
      end
    end
  end

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"

  delete "logout", to: "sessions#destroy"

  
end