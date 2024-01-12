module PasswordResetService
  class ValidatePasswordResetToken
    def self.validate_password_reset_token(password_reset_token)
      token_record = PasswordResetToken.find_by(token: password_reset_token)
      if token_record && !token_record.used && token_record.expires_at > Time.now
        token_record.user_id
      else
        { error: 'Password reset token is invalid or has expired.' }
      end
    end
  end
end
