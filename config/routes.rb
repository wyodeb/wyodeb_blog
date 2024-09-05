Rails.application.routes.draw do
  root "posts#index"
  resources :posts, param: :slug do
    resources :comments, only: [:create, :update, :destroy]
  end
  resources :comments, only: %i[update destroy]
  devise_for :users, controllers: { sessions: 'sessions' }

  post 'otp/request', to: 'otp#request_otp'
  post 'otp/verify', to: 'otp#verify_otp'

  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
