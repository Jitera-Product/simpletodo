
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    resources :users, only: [] do
      collection do
        post :register, to: 'users#register'
        get :confirm
        get :validate_session, to: 'users#validate_session', as: 'validate_session'
        post :confirm_email, to: 'users#confirm_email' # New code added to meet the requirement
        post :sign_in
        post :resend_confirmation
        post :forgot_password
        post :update_password
        put :reset_password
      end
      member do
        put :profile, to: 'users#update_profile'
      end
    end
    resources :todos, only: [:create, :destroy] do
      member do
        post :cancel_deletion
        put :recover
      end
    end
    # ... other resources ...
  end
end
