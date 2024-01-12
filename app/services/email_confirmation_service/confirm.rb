# rubocop:disable Style/ClassAndModuleChildren
class EmailConfirmationService::Confirm
  attr_accessor :token
  def initialize(token)
    @token = token
  end
  def execute
    email_confirmation = EmailConfirmation.find_by(token: token)
    unless email_confirmation
      raise 'Invalid token'
    end

    if Time.current > email_confirmation.expires_at
      raise 'Token has expired'
    end

    user = User.find(email_confirmation.user_id)
    raise 'User not found' unless user
    user.update(email_confirmed: true)
    email_confirmation.destroy
    { success: 'Email confirmed successfully' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
