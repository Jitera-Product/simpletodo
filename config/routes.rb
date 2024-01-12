require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    resources :users, only: [] do
      collection do
        post 'todo_folders' => 'todo_folders#create', as: :create_todo_folder # New code addition
        post :create, to: 'todo_folders#create' # Existing code addition, consider renaming or merging functionality
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
        post :abort_creation # Existing code addition
        put :recover
      end
    end
  end
end
