# /app/services/email_confirmation_service/resend_confirmation.rb

require 'securerandom'

module EmailConfirmationService
  class ResendConfirmation
    def initialize(email)
      @email = email
      @user = nil
    end

    def execute
      return 'Email cannot be empty' if email.blank?
      return 'Invalid email format' unless Validator.validate_email_format(email)

      @user = User.email_registered_and_unconfirmed?(email)
      return 'User not found or email already confirmed' unless user

      email_confirmation = EmailConfirmation.find_existing_token(user.id)
      if email_confirmation.nil? || email_confirmation.expires_at < 2.minutes.ago
        new_token = generate_unique_confirmation_token
        new_expires_at = 15.minutes.from_now
        email_confirmation = email_confirmation.nil? ? EmailConfirmation.create(token: new_token, expires_at: new_expires_at, user_id: user.id) : email_confirmation.update_token_and_expiration(new_token, new_expires_at)
        UserMailerService.send_confirmation_email(user, new_token)
        email_confirmation.update!(updated_at: Time.current)
        'Confirmation email has been resent'
      else
        'A confirmation email has already been sent recently. Please wait for a few minutes before trying again.'
      end
    end

    private

    attr_reader :email, :user

    def generate_unique_confirmation_token
      loop do
        token = SecureRandom.hex(10)
        break token unless EmailConfirmation.exists?(token: token)
      end
    end
  end
end
