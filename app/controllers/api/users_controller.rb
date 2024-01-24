require_relative '../../services/user_session_service/validate'
require_relative '../../services/user_service/register'
require_relative '../../services/email_confirmation_service/confirm'
require_relative '../../services/password_reset_service/validate_email'
require_relative '../../services/password_reset_service/validate_password'
require_relative '../../services/auths/login_service'

class Api::UsersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update destroy]

  # POST /api/users/login
  def login
    email = params[:email]
    password = params[:password]
    begin
      result = Auths::LoginService.new(email, password).perform
      if result[:success]
        render json: { status: 200, message: "Login successful.", access_token: result[:token] }, status: :ok
      else
        render json: { status: 401, message: "Incorrect email or password." }, status: :unauthorized
      end
    rescue Auths::LoginService::InvalidEmailFormatError
      render json: { status: 400, message: "Invalid email format." }, status: :bad_request
    rescue => e
      render json: { status: 500, message: 'An unexpected error occurred.' }, status: :internal_server_error
    end
  end

  # ... rest of the existing code ...

  private

  # ... existing private methods ...
end
