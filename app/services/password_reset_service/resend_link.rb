# /app/services/password_reset_service/resend_link.rb

class PasswordResetService::ResendLink
  def initialize(email)
    @user = User.find_by(email: email)
  end

  def execute
    return 'Email not found' unless @user

    token = find_valid_token
    if token
      send_password_reset_email(token)
    else
      initiate_password_reset
    end
  end

  private

  def find_valid_token
    @user.password_reset_tokens.where('expires_at > ? AND used = ?', Time.current, false).last
  end

  def send_password_reset_email(token)
    # Assuming MailerService is a service responsible for sending emails
    if MailerService.send_password_reset_email(@user.email, token)
      log_password_reset_activity(@user.email, 'resend_link', 'success')
      'Password reset link has been resent successfully'
    else
      log_password_reset_activity(@user.email, 'resend_link', 'failed')
      'Failed to send password reset link'
    end
  end

  def initiate_password_reset
    initiate_service = PasswordResetService::InitiatePasswordReset.new(@user.email)
    initiate_service.execute
  end

  def log_password_reset_activity(email, action, status)
    # Assuming LoggerService is a service responsible for logging activities
    LoggerService.log_password_reset_activity(email, action, status)
  end
end
