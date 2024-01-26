
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    resources :users, only: [] do
      collection do
        post :register
        post :resend_confirmation
        get :confirm
        get 'confirm/:confirmation_token', to: 'users#confirm', as: :confirm_email
        post 'confirm-password-reset', to: 'users#confirm_password_reset'
        get :validate_session
        post :sign_in
        post :forgot_password
        put :reset_password
        post 'login', to: 'users#login', as: :login
        post 'request-password-reset', to: 'users#request_password_reset'
      end
    end

    namespace :v2 do
      resources :users, only: [] do
        collection do
          get :validate_session_v2 # Updated to match the requirement
        end
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
