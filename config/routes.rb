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

  # rotas existentes
  resources :notifications, only: [ :index ] do
    member do
      patch :mark_as_read
    end
  end
  resources :properties
  resources :visits, only: [ :create, :index ]
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
end
