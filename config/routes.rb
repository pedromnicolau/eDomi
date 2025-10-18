Rails.application.routes.draw do
  devise_for :users

  root to: "properties#index"

  # Painel admin
  namespace :admin do
    resources :properties
    resources :sales
    resources :visits
  end

  # Painel corretor
  namespace :agent do
    resources :properties do
      resources :visits, only: [ :index, :show, :edit, :update, :destroy ]
    end
    resources :sales, only: [ :index, :show ]
  end

  # Para compradores
  resources :properties, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :visits, only: [ :new, :create, :edit, :update ]
    member do
      delete "remove_photo/:photo_id", to: "properties#remove_photo", as: :remove_photo
    end
  end

  resources :sales, only: [ :index, :show ]  # histórico de compras

  # Páginas estáticas
  get 'politica-de-privacidade', to: 'pages#privacy_policy', as: :privacy_policy
  get 'termos-de-uso',           to: 'pages#terms',           as: :terms
  get 'sobre',                   to: 'pages#about',           as: :about
  get 'contato',                 to: 'pages#contact',         as: :contact
  post 'contato',                to: 'pages#submit_contact',  as: :submit_contact
end
