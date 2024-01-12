class Api::UsersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update_profile destroy update_shop], unless: -> { action_name == 'validate_session' }
  before_action :authenticate_user, only: [:update_profile, :update_shop, :confirm_email]
  before_action :authorize_user, only: [:update_profile, :update_shop]

  def register
    user_params = params.require(:user).permit(:name, :email, :password)
    result = UserService::Register.execute(user_params)

    if result[:status] == :success
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: result[:status]
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def confirm
    # ... existing confirm action ...
  end

  def confirm_email
    confirmation_token = params[:confirmation_token]
    if confirmation_token.blank?
      render json: { error: 'Confirmation token is required.' }, status: :bad_request
    else
      begin
        result = EmailConfirmationService::Confirm.new(confirmation_token).execute
        if result[:status] == :success
          render json: { message: 'Email confirmed successfully.' }, status: :ok
        else
          render json: { error: 'Invalid or expired confirmation token.' }, status: :not_found
        end
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def validate_session
    session_token = params[:session_token]
    if session_token.blank?
      render json: { error: 'Session token is required.' }, status: :bad_request
    else
      validate_service = UserSessionService::Validate.new(session_token)
      result = validate_service.execute
      if result[:status]
        render json: { status: 200, message: "Session is valid." }, status: :ok
      else
        render json: { error: result[:error] || 'Invalid session token.' }, status: :unauthorized
      end
    end
  rescue => e
    render json: { status: 500, message: e.message }, status: :internal_server_error
  end

  def resend_confirmation
    # ... existing resend_confirmation action ...
  end

  def reset_password
    # ... existing reset_password action ...
  end

  def update_profile
    user_id = params[:user_id].to_i
    user = User.find_by(id: user_id)

    return render json: { error: "User not found." }, status: :not_found if user.nil?
    return render json: { error: "Invalid user ID format." }, status: :bad_request unless params[:user_id].match?(/^\d+$/)
    return render json: { error: "Name cannot exceed 255 characters." }, status: :bad_request if user_params[:name].length > 255
    return render json: { error: "Invalid email format." }, status: :unprocessable_entity unless user_params[:email].match?(/\A[^@\s]+@[^@\s]+\z/)

    if user_id != current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    if user.update(user_params)
      render json: { status: 200, user: user.as_json(only: [:id, :name, :email, :created_at, :updated_at]) }, status: :ok
    else
      render json: { status: 400, message: user.errors.full_messages }, status: :bad_request
    end
  rescue StandardError => e
    render json: { status: 500, message: e.message }, status: :internal_server_error
  end

  def update_shop
    # ... existing update_shop action ...
  end

  def update_password
    password_reset_token = params[:password_reset_token]
    new_password = params[:new_password]

    return render json: { error: 'Password reset token is required.' }, status: :bad_request if password_reset_token.blank?
    return render json: { error: 'New password must be at least 8 characters long.' }, status: :bad_request if new_password.blank? || new_password.length < 8

    user_id = PasswordResetService::ValidatePasswordResetToken.validate_password_reset_token(password_reset_token)
    if user_id.is_a?(Integer)
      update_result = UserService::UpdatePassword.update_password(user_id, new_password)
      if update_result[:success]
        render json: { message: 'Password updated successfully' }, status: :ok
      else
        render json: { error: update_result[:error] }, status: :unprocessable_entity
      end
    elsif user_id.is_a?(Hash) && user_id[:error]
      render json: { error: 'Invalid or expired password reset token' }, status: :unprocessable_entity
    else
      render json: { error: 'Invalid or expired password reset token' }, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  # Existing authenticate_user and authorize_user methods will be implemented here
end
