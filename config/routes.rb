Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  namespace :api do
    resources :users, only: [] do
      collection do
        post 'notifications', to: 'notifications#create' # This line is added to meet the requirement
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
    resources :folders, only: [:create] do
      post :validate, to: 'folders#validate' # This line is added to meet the requirement
      member do
        post :cancel_creation
        post :cancel, to: 'folders#cancel'
      end
    end
    post 'folders/validation-errors', to: 'folders#validation_errors'
    get 'folders/check_name_uniqueness', to: 'folders#check_name_uniqueness'
  end
end
