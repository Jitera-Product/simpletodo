# rubocop:disable Style/ClassAndModuleChildren
class UserService::ResendConfirmation
  attr_accessor :email
  def initialize(email)
    @email = email
  end
  def execute
    user = User.find_by(email: email)
    return { error: 'Email does not exist or is already confirmed.' } unless user && !user.email_confirmed
    confirmation_token = UserService::GenerateConfirmationToken.new(user.id).execute
    UserService::SendConfirmationEmail.new(email, confirmation_token).execute
    { success: 'Confirmation email has been resent.' }
  rescue StandardError => e
    { error: e.message }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
