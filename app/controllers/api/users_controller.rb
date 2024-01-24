require_relative '../../services/user_session_service/validate'
require_relative '../../services/user_service/register'
require_relative '../../services/user_service/resend_confirmation'
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

  def resend_confirmation
    email = params[:email]
    if email.blank?
      render json: { status: 400, message: "Email is required." }, status: :bad_request
      return
    end

    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { status: 400, message: "Invalid email format." }, status: :bad_request
      return
    end

    begin
      result = execute_resend_confirmation(email)
      if result[:success]
        render json: { status: 200, message: result[:success] }, status: :ok
      else
        case result[:error]
        when "Email is already confirmed."
          render json: { status: 400, message: result[:error] }, status: :bad_request
        when "Email not found."
          render json: { status: 404, message: result[:error] }, status: :not_found
        when "Please wait for 2 minutes before requesting again."
          render json: { status: 429, message: result[:error] }, status: :too_many_requests
        else
          render json: { status: 422, message: result[:error] }, status: :unprocessable_entity
        end
      end
    rescue => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

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

  def execute_resend_confirmation(email)
    UserService::ResendConfirmation.new(email).call
  rescue UserService::ResendConfirmation::EmailNotFoundError => e
    { error: e.message }
  rescue UserService::ResendConfirmation::EmailAlreadyConfirmedError => e
    { error: e.message }
  rescue UserService::ResendConfirmation::TooManyRequestsError => e
    { error: e.message }
  end
end
