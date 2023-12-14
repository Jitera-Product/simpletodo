# PATH: /config/routes.rb
require 'sidekiq/web'
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  namespace :api do
    resources :users, only: [] do
      collection do
        get :confirm
        get :validate_session
        post :sign_in
        post :resend_confirmation
        post :forgot_password
        put :reset_password
      end
    end
    resources :todos, only: [:create, :destroy] do
      member do
        post :cancel_deletion
        put :recover
      end
      resources :attachments, only: [:create], controller: 'attachments' do
        collection do
          post :upload_attachments
        end
      end
    end
  end
end
