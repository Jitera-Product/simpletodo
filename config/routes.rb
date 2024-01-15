require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  namespace :api do
    resources :users, only: [] do
      collection do
        post 'notifications', to: 'notifications#create' # This line is added to meet the requirement
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
      post :folders, to: 'folders#create'
      member do
        post :cancel_deletion
        put :recover
      end
    end
    resources :folders, only: [:create] do # Keep the restriction to only the :create action
      post :notifications, to: 'notifications#create' # This line is from the new code
      member do
        post :cancel, to: 'folders#cancel' # This line already satisfies the requirement for the cancel folder creation endpoint
        post :cancel_creation
      end
    end
    post 'folders/validation-errors', to: 'folders#validation_errors'
    get 'folders/check_name_uniqueness', to: 'folders#check_name_uniqueness'
    # The following line is added to meet the requirement for creating a custom folder
    post 'folders/custom', to: 'folders#create_custom' # This is the endpoint for creating a custom folder
  end
end
