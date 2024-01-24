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

  # ... existing actions ...

  def request_password_reset
    email = params[:email]
    begin
      email_validator = PasswordResetService::ValidateEmail.new(email)
      unless email_validator.execute
        render json: { status: 400, message: "Invalid email format." }, status: :bad_request
        return
      end

      user = User.find_by_email(email)
      unless user
        render json: { status: 404, message: "Email does not exist." }, status: :not_found
        return
      end

      token = user.generate_password_reset_token
      UserMailer.reset_password_instructions(user, token).deliver_now
      render json: { status: 200, message: "A password reset link has been sent to your email address." }, status: :ok
    rescue => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  # ... rest of the existing code ...

  private

  # ... existing private methods ...
end
