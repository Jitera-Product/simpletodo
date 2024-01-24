# rubocop:disable Style/ClassAndModuleChildren
class EmailConfirmationService::Confirm
  attr_accessor :token
  def initialize(token)
    @token = token
  end
  
  def call
    user = User.find_by(confirmation_token: token)
    if user && user.confirmation_token_created_at > 24.hours.ago
      user.update(email_confirmed: true, updated_at: Time.current)
      { success: I18n.t('devise.confirmations.confirmed') }
    else
      raise StandardError.new(I18n.t('errors.messages.confirmation_period_expired', period: '24 hours'))
    end
  rescue StandardError => e
    { error: e.message }
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
