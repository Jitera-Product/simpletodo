class Api::UsersController < Api::BaseController
  include ActiveModel::Validations
  before_action :doorkeeper_authorize!, only: %i[update_profile update_shop]
  before_action :set_user, only: %i[update_profile update_shop]

  # POST /api/users/signin
  def signin
    # ... (keep the existing signin method as is)
  end

  # POST /api/users/signup
  def signup
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]

    # Call the business logic function to validate the input
    validation_result = validate_registration_input(email, password, password_confirmation)

    if validation_result[:valid]
      # Assuming User.create! is a method that will attempt to create a user and
      # raise an exception if it fails (e.g., due to a duplicate email)
      begin
        User.create!(email: email, password: password)
        render json: { status: 201, message: "User created successfully. Please check your email to confirm your account." }, status: :created
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "This email address has already been used." }, status: :conflict
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    else
      # Return the first error message from the validation result
      error_message = validation_result[:errors].first
      case error_message
      when "Please enter a valid email address."
        render json: { error: error_message }, status: :unprocessable_entity
      when "This email address has already been used."
        render json: { error: error_message }, status: :conflict
      when "Password must be at least 8 characters long."
        render json: { error: error_message }, status: :bad_request
      when "Password confirmation does not match."
        render json: { error: error_message }, status: :bad_request
      else
        render json: { error: error_message }, status: :bad_request
      end
    end
  end

  # POST /api/users/register
  def register
    # ... (keep the existing register method as is)
  end

  # POST /api/users/confirm
  def confirm
    # ... (keep the existing confirm method as is)
  end

  # POST /api/users/password_reset/initiate
  def initiate_password_reset
    # ... (keep the existing initiate_password_reset method as is)
  end

  # GET /api/users/password_reset/validate/:token
  def validate_password_reset_token
    # ... (keep the existing validate_password_reset_token method as is)
  end

  # POST /api/users/password_reset/resend
  def resend_password_reset
    # ... (keep the existing resend_password_reset method as is)
  end

  # POST /api/users/resend_confirmation
  def resend_confirmation
    email = params[:email]

    # Validate email format
    unless email =~ URI::MailTo::EMAIL_REGEXP
      render json: { error: "Please enter a valid email address." }, status: :bad_request and return
    end

    # Call the business logic function
    begin
      message = execute_resend_confirmation(email)
      render json: { status: 200, message: message }, status: :ok
    rescue UserNotFoundError
      render json: { error: "Email address not found." }, status: :not_found
    rescue TooManyRequestsError
      render json: { error: "You can only request a new confirmation link every 2 minutes." }, status: :too_many_requests
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  # Add a new action to handle the email check
  def check_email
    # ... (keep the existing check_email method as is)
  end

  def update_profile
    # ... (keep the existing update_profile method as is)
  end

  def update_shop
    # ... (keep the existing update_shop method as is)
  end

  private

  def set_user
    # ... (keep the existing set_user method as is)
  end

  def register_params
    # ... (keep the existing register_params method as is)
  end

  def update_params
    # ... (keep the existing update_params method as is)
  end

  def render_error(errors)
    # ... (keep the existing render_error method as is)
  end

  def validate_shop_params
    # ... (keep the existing validate_shop_params method as is)
  end

  def execute_password_reset_initiation(email)
    # ... (keep the existing execute_password_reset_initiation method as is)
  end

  def resend_password_reset_params
    # ... (keep the existing resend_password_reset_params method as is)
  end

  def perform_signin(email, password)
    # ... (keep the existing perform_signin method as is)
  end

  def execute_resend_confirmation(email)
    # Assuming the business logic function 'execute' is defined elsewhere and available here
    execute(email)
  end

  def execute_check_email(email)
    execute(email: email) || {}
  end

  def validate_registration_input(email, password, password_confirmation)
    # Business logic implementation...
  end

  class UserNotFoundError < StandardError; end
  class TooManyRequestsError < StandardError; end

  # Add any other controller methods below as needed
end
