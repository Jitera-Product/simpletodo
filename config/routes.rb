require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  namespace :api do
    resources :users, only: [] do
      collection do
        # Other user routes
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
    end
    resources :folders, only: [:create] do # Updated to include only the :create action
      member do
        post :cancel_creation
        post :cancel, to: 'folders#cancel' # This line was added to meet the requirement
      end
    end
    get 'folders/check_name_uniqueness', to: 'folders#check_name_uniqueness'
  end
end
