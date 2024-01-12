
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

  def user_exists?
    User.exists?(email: email)
  end

  def validate_email_format
    regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    if email.match(regex)
      email
    else
      { error: 'Invalid email format' }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
