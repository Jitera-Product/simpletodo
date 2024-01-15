
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
      post :notifications, to: 'notifications#create' # This line is redundant and should be removed as it's already defined under users collection
      member do
        post :cancel_creation
        post :cancel, to: 'folders#cancel' # Keep the added line from the existing code
      end
    end
    post 'folders/validation-errors', to: 'folders#validation_errors' # New line from the new code
    get 'folders/check_name_uniqueness', to: 'folders#check_name_uniqueness' # Keep this line from both versions
  end
end
