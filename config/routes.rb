Rails.application.routes.draw do
  # usar controller customizado para sessions, registrations e passwords
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }, skip: [ :sessions, :registrations, :passwords ]

  # Rotas Devise customizadas para API/SPA
  devise_scope :user do
    # Sessions
    post "users/sign_in", to: "users/sessions#create"
    delete "users/sign_out", to: "users/sessions#destroy"

    # Registrations
    post "users", to: "users/registrations#create"
    put "users", to: "users/registrations#update"
    patch "users", to: "users/registrations#update"
    delete "users", to: "users/registrations#destroy"

    # Passwords
    post "users/password", to: "users/passwords#create"
    put "users/password", to: "users/passwords#update"
    patch "users/password", to: "users/passwords#update"

    # First-time password setup for OAuth users
    post "users/password/set", to: "users/passwords#set"
  end

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

  # rotas existentes
  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end
  end
  resources :properties
  resources :visits, only: [ :create, :index ] do
    member do
      patch :accept
      patch :reject
    end
  end
  get "/current_user", to: "users#current"

  # adicionadas: endpoints JSON utilizados pelo frontend
  resources :agents, only: [ :index ]            # GET /agents(.json) => lista de corretores
  resources :sales, only: [ :index ]             # GET /sales(.json) => lista de vendas (imóveis vendidos)
  resources :commissions, only: [ :index, :create ] do
    collection do
      get :report                              # GET /commissions/report(.json)
    end
  end

  # users index for admin UI (JSON)
  resources :users, only: [ :index ]

  resources :people, only: [ :index, :show, :create, :update, :destroy ]
  resources :contacts, only: [ :create ]

  # Kanban / Sales pipeline API
  resources :kanban_boards, only: [ :index, :show, :create, :update, :destroy ]
  resources :kanban_columns, only: [ :create, :update, :destroy ] do
    collection do
      post :reorder
    end
  end
  resources :kanban_cards, only: [ :create, :show, :update, :destroy ] do
    collection do
      post :reorder
    end
  end
end
