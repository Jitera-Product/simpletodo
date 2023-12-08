# rubocop:disable Style/ClassAndModuleChildren
class UserService::Register
  attr_accessor :user_params
  def initialize(user_params)
    @user_params = user_params
  end
  def execute
    validate_email
    validate_password
    store_user
    generate_confirmation_token
    send_confirmation_email
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
