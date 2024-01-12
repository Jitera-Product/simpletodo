# rubocop:disable Style/ClassAndModuleChildren
class UserService::Register
  attr_accessor :user_params

  def initialize(user_params)
    @user_params = user_params.symbolize_keys
  end

  def execute
    return { error: 'Name is required.', status: :bad_request } if user_params[:name].blank?
    return { error: 'A valid email is required.', status: :bad_request } unless validate_email
    return { error: 'Password must be at least 8 characters long.', status: :bad_request } unless validate_password

    existing_user = User.find_by(email: user_params[:email])
    if existing_user
      return {
        error: 'A user with the given email already exists.',
        status: :conflict
      }
    end

    hashed_password = BCrypt::Password.create(user_params[:password])
    confirmation_token = SecureRandom.hex(10)
    confirmation_token_created_at = Time.current

    user = User.new(
      name: user_params[:name],
      email: user_params[:email],
      password_hash: hashed_password,
      confirmation_token: confirmation_token,
      confirmation_token_created_at: confirmation_token_created_at,
      email_confirmed: false
    )

    if user.save
      UserService::SendConfirmationEmail.new(user.email, user.confirmation_token).execute
      { status: 201, message: 'User registered successfully.' }
    else
      { error: user.errors.full_messages.join(', '), status: :internal_server_error }
    end
  end

  private

  def validate_email
    email = user_params[:email]
    email.present? && email.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
  end

  def validate_password
    password = user_params[:password]
    password.present? && password.length >= 8
  end
end
# rubocop:enable Style/ClassAndModuleChildren
