# /app/services/email_confirmation_service/validator.rb

module EmailConfirmationService
  class Validator
    def self.validate_confirmation_token(confirmation_token)
      raise ArgumentError, 'Confirmation token cannot be blank' if confirmation_token.blank?

      token_record = EmailConfirmation.find_by(token: confirmation_token)
      return false unless token_record && !token_expired?(token_record)

      true
    end

    def self.token_expired?(token_record)
      token_record.expires_at < Time.current
    end
  end
end
