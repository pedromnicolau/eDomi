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
  resources :properties, only: [ :index, :show, :new, :create, :edit, :update ] do
    resources :visits, only: [ :new, :create, :edit, :update ]
  end

  resources :sales, only: [ :index, :show ]  # histórico de compras
end
