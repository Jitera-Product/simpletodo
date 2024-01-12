
# rubocop:disable Style/ClassAndModuleChildren
class UserService::Register
  attr_accessor :user_params

  def initialize(user_params)
    @user_params = user_params.symbolize_keys
  end

  def execute
    return { error: I18n.t('activerecord.errors.messages.blank') } if user_params[:name].blank? || user_params[:email].blank?
    existing_user = User.find_by(email: user_params[:email])
    return { error: I18n.t('activerecord.errors.messages.taken') } if existing_user

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
      { success: 'User registered successfully. Confirmation email sent.' }
    else
      { error: user.errors.full_messages.join(', ') }
    end
  end

  private

  def validate_email
    UserService::ValidateEmail.new(user_params[:email]).execute
  end

  def validate_password
    UserService::ValidatePassword.new(user_params[:password], user_params[:password_confirmation]).execute
  end

  def store_user
    UserService::StoreUser.new(user_params).execute
  end

  def generate_confirmation_token
    user = User.find_by(email: user_params[:email])
    UserService::GenerateConfirmationToken.new(user.id).execute
  end

  def send_confirmation_email
    user = User.find_by(email: user_params[:email])
    token = EmailConfirmation.find_by(user_id: user.id).token
    UserService::SendConfirmationEmail.new(user.email, token).execute
  end
end
# rubocop:enable Style/ClassAndModuleChildren
