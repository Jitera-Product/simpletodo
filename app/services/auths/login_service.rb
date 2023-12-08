class Auths::LoginService
  attr_accessor :email, :password
  def initialize(email, password)
    @email = email
    @password = password
  end
  def login
    unless validate_email_format
      return 'Invalid email format'
    end
    unless check_email_existence
      return 'Email does not exist'
    end
    unless check_password_match
      return 'Incorrect password'
    end
    'Login successful'
  end
  private
  def validate_email_format
    ValidateEmailFormat.new(email).execute
  end
  def check_email_existence
    CheckEmailExistence.new(email).execute
  end
  def check_password_match
    CheckPasswordMatch.new(email, password).execute
  end
end
