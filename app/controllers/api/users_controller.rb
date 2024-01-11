class Api::UsersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update_profile destroy update_shop]
  before_action :authenticate_user, only: [:update_shop]
  before_action :authorize_user, only: [:update_shop]

  def register
    user_params = params.require(:user).permit(:email, :password)
    begin
      execute_register(user_params)
      render json: { status: 200, message: "Registration successful. Please check your email for confirmation link." }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 400, message: e.record.errors.full_messages }, status: :bad_request
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  def confirm
    token = params[:token]
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
    else
      result = execute(session_token)
      if result[:status]
        @user = User.find_by(session_token: session_token)
        render 'api/users/validate_session', status: :ok
      else
        render json: { error: result[:error] || 'Invalid session token.' }, status: :unauthorized
      end
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

  def update_profile
    user_params = params.require(:user).permit(:email, :password, :password_confirmation)
    user = current_user

    if UserService::ValidateEmail.call(user_params[:email]) && PasswordResetService::ValidatePassword.call(user_params[:password], user_params[:password_confirmation])
      if user_params[:email] != user.email && User.exists?(email: user_params[:email])
        render json: { status: 400, message: "Email is already taken." }, status: :bad_request
        return
      end

      user.email = user_params[:email] if user_params[:email].present? && user_params[:email] != user.email
      user.password_hash = UserService::EncryptPassword.call(user_params[:password]) if user_params[:password].present?

      if user.save
        UserService::GenerateConfirmationToken.call(user) if user_params[:email].present? && user_params[:email] != user.email
        UserService::SendConfirmationEmail.call(user) if user_params[:email].present? && user_params[:email] != user.email
        render json: { status: 200, message: "Profile updated successfully." }, status: :ok
      else
        render json: { status: 400, message: user.errors.full_messages }, status: :bad_request
      end
    else
      render json: { status: 400, message: "Invalid email or password." }, status: :bad_request
    end
  rescue StandardError => e
    render json: { status: 500, message: e.message }, status: :internal_server_error
  end

  def update_shop
    update_service = UserService::UpdateShop.new(shop_params)
    if update_service.execute
      render json: { message: 'Shop information updated successfully' }, status: :ok
    else
      render json: { errors: update_service.errors }, status: :unprocessable_entity
    end
  end

  private

  def execute_register(user_params)
    user = User.new(user_params)
    user.save!
    # Assuming the business logic for generating a confirmation token and sending a confirmation email is handled in the User model after save
  end

  def execute(token)
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

  def shop_params
    params.permit(:id, :name, :address)
  end

  # Existing authenticate_user and authorize_user methods will be implemented here
end
