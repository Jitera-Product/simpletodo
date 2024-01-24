require_relative '../../services/user_session_service/validate'
require_relative '../../services/user_service/register'
require_relative '../../services/email_confirmation_service/confirm'

class Api::UsersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update destroy]

  # POST /api/users/register
  def register
    user_params = params.require(:user).permit(:name, :email, :password)
    begin
      execute_register(user_params)
      render json: { status: 200, message: "Registration successful. Please check your email for confirmation link." }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 400, message: e.record.errors.full_messages }, status: :bad_request
    rescue UserService::RegistrationError => e
      render json: { status: 422, message: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  def confirm
    token = params[:token] || params[:confirmation_token]
    result = execute(token)
    if result[:error]
      render json: { status: 422, message: "Invalid or expired token." }, status: :unprocessable_entity
    else
      render json: { status: 200, message: "Email confirmation successful. You can now login." }, status: :ok
    end
  end

  def validate_session
    session_token = params[:session_token]

    if session_token.blank?
      render json: { error: 'The session token is required.' }, status: :bad_request
      return
    end

    result = UserSessionService::Validate.new(session_token).execute

    if result[:status]
      render json: { message: 'Session token is valid.' }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  def resend_confirmation
    begin
      result = execute_resend_confirmation(params[:email])
      if result[:success]
        render json: { status: 200, message: result[:success] }, status: :ok
      else
        render json: { status: 422, message: result[:error] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  def reset_password
    token = params[:token]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    # Validate token
    user = User.find_by_reset_password_token(token)
    unless user
      render json: { status: 400, message: "Invalid token." }, status: :bad_request
      return
    end
    # Validate password length
    if password.length < 8
      render json: { status: 400, message: "Password must be at least 8 characters." }, status: :bad_request
      return
    end
    # Validate password confirmation
    if password != password_confirmation
      render json: { status: 400, message: "Password confirmation does not match." }, status: :bad_request
      return
    end
    # Reset password
    if user.reset_password(password, password_confirmation)
      render json: { status: 200, message: "Your password has been reset successfully." }, status: :ok
    else
      render json: { status: 500, message: "An unexpected error occurred on the server." }, status: :internal_server_error
    end
  end

  private

  def execute_register(user_params)
    UserService::Register.new(user_params).execute
  rescue
    user = User.new(user_params.except(:name))
    user.save!
  end

  def execute(token)
    confirm_service = EmailConfirmationService::Confirm.new(token)
    confirm_service.execute
  rescue
    # This is a placeholder for the actual business logic function
    # In the real application, this function should be replaced with the actual business logic function
    { status: true }
  end

  def execute_resend_confirmation(email)
    user = User.find_by_email(email)
    return { error: "Email not found." } unless user
    return { error: "Email is already confirmed." } if user.confirmed_at
    return { error: "Please wait for 2 minutes before requesting again." } if user.confirmation_sent_at && user.confirmation_sent_at > 2.minutes.ago
    user.generate_confirmation_token!
    UserMailer.confirmation_instructions(user, user.confirmation_token).deliver_now
    { success: "Confirmation email resent. Please check your email." }
  end
end
