class Api::UsersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create update_profile destroy update_shop]
  before_action :authenticate_user, only: [:update_profile, :update_shop]
  before_action :authorize_user, only: [:update_profile, :update_shop]

  def register
    # ... existing register action ...
  end

  def confirm
    # ... existing confirm action ...
  end

  def validate_session
    session_token = params[:session_token]
    if session_token.blank?
      render json: { error: 'Session token is required.' }, status: :unprocessable_entity
    else
      validate_service = UserSessionService::Validate.new(session_token)
      result = validate_service.execute
      if result[:status]
        render json: { message: "Session is valid." }, status: :ok
      else
        render json: { error: result[:error] }, status: :unauthorized
      end
    end
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

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def execute_register(user_params)
    # ... existing execute_register method ...
  end

  def execute(token)
    # ... existing execute method ...
  end

  def execute_resend_confirmation(email)
    # ... existing execute_resend_confirmation method ...
  end

  def shop_params
    # ... existing shop_params method ...
  end

  # Existing authenticate_user and authorize_user methods will be implemented here
end
