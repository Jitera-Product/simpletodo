# rubocop:disable Style/ClassAndModuleChildren
class EmailConfirmationService::Confirm
  attr_accessor :token
  def initialize(token)
    @token = token
  end
  def execute
    email_confirmation = EmailConfirmation.find_by(token: token)
    return { error: 'Invalid token' } unless email_confirmation
    user = User.find(email_confirmation.user_id)
    user.update(email_confirmed: true)
    email_confirmation.destroy
    { success: 'Email confirmed successfully' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
