# /app/services/password_reset_service/token_validator.rb

class PasswordResetService::TokenValidator
  def self.validate_token(token)
    password_reset_token = PasswordResetToken.find_by(token: token, used: false)
    
    if password_reset_token && password_reset_token.expires_at > Time.current
      password_reset_token.update(used: true)
      response_message = PasswordResetService::Response.generate_response_message(true)
    else
      PasswordResetService::Logger.log_invalid_token_attempt(token)
      response_message = PasswordResetService::Response.generate_response_message(false)
    end

    response_message
  end
end
