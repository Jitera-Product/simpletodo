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
      member do
        put :profile, to: 'users#update_profile'
      end
    end
    resources :todos, only: [:create, :destroy] do
      member do
        post :cancel_deletion
        post :abort_folder_creation, to: 'todos#abort_folder_creation' # New code added here
        put :recover
      end
    end
    post '/todo_folders', to: 'todo_folders#create' # Existing code preserved here
    # ... other resources ...
  end
end
