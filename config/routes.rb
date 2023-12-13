
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    # User password reset routes
    post 'users/password_reset/resend', to: 'users#resend_password_reset'
    get 'users/validate_password_reset_token/:token', to: 'users#validate_password_reset_token'
    post 'users/password_reset/initiate', to: 'users#initiate_password_reset'
    put 'users/password_reset/reset', to: 'users#reset_password'

    # Todo item routes
    resources :todos, only: [:index, :create, :destroy] # Combined existing route for creating a todo item with the new destroy action

    get 'todos/:id/trash', to: 'todos#trash' # New route for completing a to-do item
    post 'todos/:id/cancel_deletion', to: 'todos#cancel_deletion' # New route for canceling the deletion of a to-do item
    post 'todos/:todo_id/attach_files', to: 'todos#attach_files' # Existing route for attaching files to a todo item
    post 'todos/validate', to: 'todos#validate' # Existing route for todo validation

    # New route for the signin action in UsersController
    post 'users/signin', to: 'users#signin'

    # New route for checking email availability
    get 'users/check_email', to: 'users#check_email' # Changed from post to get as per the controller action

    # New route for user registration
    post 'users/register', to: 'users#register'

    # Add the new route for the resend_confirmation action
    post 'users/resend_confirmation', to: 'users#resend_confirmation'

    # Add the new route for the signup action in UsersController
    post 'users/signup', to: 'users#signup' # This is the new route based on the provided controller action

    # Add the existing route for the confirm_email action in UsersController
    get 'users/confirm_email/:token', to: 'users#confirm_email' # This route was missing in the new code and has been added back

    # Add the new route for retrieving comments for a given todo item
    get 'todos/:todo_id/comments', to: 'todos#comments_for_todo' # This is the new route as per the guideline
  end
end
