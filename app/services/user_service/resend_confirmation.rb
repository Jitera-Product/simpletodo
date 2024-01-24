
# rubocop:disable Style/ClassAndModuleChildren
class UserService::ResendConfirmation
  attr_accessor :email
  def initialize(email)
    @email = email
  end

  def call
    user = User.find_by(email: email)
    return { error: 'Email does not exist or is already confirmed.' } unless user && !user.email_confirmed

    last_request = EmailConfirmationRequest.where(user_id: user.id).order(requested_at: :desc).first
    return { error: 'Please wait at least 2 minutes before requesting another confirmation email.' } if last_request && last_request.requested_at > 2.minutes.ago

    user.generate_confirmation_token_and_update

    EmailConfirmationRequest.create!(
      user_id: user.id,
      requested_at: Time.current,
      created_at: Time.current,
      updated_at: Time.current
    )

    UserMailer.send_confirmation_email(user, user.confirmation_token).deliver_now
    { success: 'Confirmation email has been resent.' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
