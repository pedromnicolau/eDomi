Rails.application.routes.draw do
  # usar controller customizado para sessions para capturar redirect_to na tela de login
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"  # <--- adicione isso
  }


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "spa#index"

  get "*path", to: "spa#index", constraints: ->(req) { req.format.html? }

  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
  end
  resources :properties
  resources :visits, only: [ :create, :index ]
  get "/current_user", to: "users#current"
end
