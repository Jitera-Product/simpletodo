class PasswordResetService::ValidatePassword
  attr_accessor :password, :password_confirmation
  def initialize(password, password_confirmation)
    @password = password
    @password_confirmation = password_confirmation
  end
  def execute
    return false if password.blank? || password_confirmation.blank?
    password == password_confirmation
  end
end
