
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

  def update_password_hash(user, new_password_hash)
    User.transaction do
      user.update!(encrypted_password: new_password_hash, updated_at: Time.current)
      user.invalidate_reset_token
    end
  rescue ActiveRecord::RecordInvalid => e
    # Handle the exception, log it, or re-raise as needed
    raise e
  end
end

class User < ApplicationRecord
  def invalidate_reset_token
    self.password_reset_tokens.valid.destroy_all
  end
end
