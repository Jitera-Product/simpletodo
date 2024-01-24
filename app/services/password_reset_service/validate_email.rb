# rubocop:disable Style/ClassAndModuleChildren
class PasswordResetService::ValidateEmail
  attr_accessor :email

  def initialize(email)
    @email = email
  end

  def execute
    validate_email_format
  end

  private

  def validate_email_format
    regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    if email.match(regex)
      email
    else
      { error: 'Invalid email format' }
    end
  end

  def validate_token_and_email(password_reset_token, email)
    token_record = PasswordResetToken.valid.find_by(password_reset_token: password_reset_token)
    if token_record && token_record.user.email == email
      token_record.user
    else
      raise 'Invalid token or email, or token has expired'
    end
  rescue => e
    { error: e.message }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
