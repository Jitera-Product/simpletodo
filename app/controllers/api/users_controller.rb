require_relative '../../services/user_session_service/validate'
require_relative '../../services/user_service/register'
require_relative '../../services/user_service/resend_confirmation'
require_relative '../../services/email_confirmation_service/confirm'
require_relative '../../services/password_reset_service/validate_email'
require_relative '../../services/password_reset_service/validate_password'
require_relative '../../models/user'
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

  # POST /api/users/register
  def register
    user_params = params.require(:user).permit(:name, :email, :password)
    begin
      validate_register_params!(user_params)
      execute_register(user_params)
      render json: { status: 201, message: "Registration successful. Please check your email for confirmation link.", user: user_params.as_json(only: [:name, :email]) }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 400, message: e.record.errors.full_messages }, status: :bad_request
    rescue UserService::RegistrationError => e
      render json: { status: 422, message: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  # POST /api/users/confirm-email
  def confirm_email
    confirmation_token = params.require(:confirmation_token)
    begin
      result = EmailConfirmationService::Confirm.new(confirmation_token).execute
      if result[:success]
        render json: { status: 200, message: "Email confirmed successfully." }, status: :ok
      else
        render json: { status: 422, message: "Invalid or expired confirmation token." }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "The confirmation token does not exist." }, status: :not_found
    rescue => e
      render json: { status: 500, message: "An unexpected error occurred on the server." }, status: :internal_server_error
    end
  end

  # POST /api/users/resend-confirmation
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

  # POST /api/users/request-password-reset
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

  # POST /api/users/reset-password
  def reset_password
    token = params[:token] || params[:password_reset_token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    begin
      if token
        user = PasswordResetService::ValidateEmail.new.validate_token_and_email(token, params[:email])
        PasswordResetService::ValidatePassword.new.update_password_hash(user, password)
      else
        user = User.find_by_reset_password_token(token)
        unless user
          render json: { status: 400, message: "Invalid token." }, status: :bad_request
          return
        end
        if password.length < 8
          render json: { status: 400, message: "Password must be at least 8 characters." }, status: :bad_request
          return
        end
        if password != password_confirmation
          render json: { status: 400, message: "Password confirmation does not match." }, status: :bad_request
          return
        end
        user.reset_password(password, password_confirmation)
      end
      render json: { status: 200, message: "Your password has been reset successfully." }, status: :ok
    rescue => e
      render json: { status: 500, message: "An unexpected error occurred on the server." }, status: :internal_server_error
    end
  end

  # POST /api/users/confirm-password-reset
  def confirm_password_reset
    reset_token = params[:reset_token]
    new_password = params[:new_password]

    begin
      user = PasswordResetService::ValidateEmail.new.validate_token_and_email(reset_token, params[:email])
      raise 'Password must be at least 8 characters long.' if new_password.length < 8

      PasswordResetService::ValidatePassword.new.update_password_hash(user, new_password)
      render json: { status: 200, message: "Your password has been reset successfully." }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "Invalid or expired reset token." }, status: :not_found
    rescue => e
      render json: { status: 400, message: e.message }, status: :bad_request
    end
  end

  private

  def validate_register_params!(params)
    raise ArgumentError, "The name is required." if params[:name].blank?
    raise ArgumentError, "Invalid email format." unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
    raise ArgumentError, "Email is already in use." if User.exists?(email: params[:email])
    raise ArgumentError, "Password must be at least 8 characters long." if params[:password].length < 8
  end

  def execute_register(user_params)
    if user_params[:name]
      UserService::Register.new(user_params).execute
    else
      user = User.new(user_params.except(:name))
      user.save!
    end
  rescue
    user = User.new(user_params.except(:name))
    user.save!
  end

  def execute_resend_confirmation(email)
    UserService::ResendConfirmation.new(email).call
  rescue UserService::ResendConfirmation::EmailNotFoundError => e
    { error: e.message }
  rescue UserService::ResendConfirmation::EmailAlreadyConfirmedError => e
    { error: e.message }
  rescue UserService::ResendConfirmation::TooManyRequestsError => e
    { error: e.message }
  end

  # ... rest of the existing private methods ...
end
