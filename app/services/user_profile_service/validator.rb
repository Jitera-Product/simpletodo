# /app/services/user_profile_service/validator.rb

class UserProfileService::Validator
  def self.validate_profile_update_params(id:, email:, password:, password_confirmation:)
    errors = {}
    errors[:id] = "ID can't be blank" if id.blank?
    errors[:email] = "Email can't be blank" if email.blank?
    errors[:password] = "Password can't be blank" if password.blank?
    errors[:password_confirmation] = "Password confirmation can't be blank" if password_confirmation.blank?
    errors[:password_confirmation] = "Password and confirmation do not match" if password != password_confirmation

    { valid: errors.empty?, errors: errors }
  end
end
