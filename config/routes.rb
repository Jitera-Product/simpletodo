require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    resources :users, only: [] do
      collection do
        post :register # Existing code addition
        post :resend_confirmation
        get :confirm
        get 'confirm/:confirmation_token', to: 'users#confirm', as: :confirm_email # Existing code addition
        get :validate_session
        post :sign_in
        post :forgot_password
        put :reset_password
      end
    end

    resources :todos, only: [:create, :destroy] do
      member do
        post :cancel_deletion
        put :recover
      end
    end
  end
end
