class AuthenticationService::SignInValidator
  def self.validate_credentials(email, password)
    return false if email.blank? || password.blank?

    user = User.find_by(email: email)
    return false unless user

    BCrypt::Password.new(user.password_hash) == password
  end
end
