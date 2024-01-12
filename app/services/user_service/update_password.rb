module UserService
  class UpdatePassword
    def self.update_password(email, new_password, password_reset_token)
      user_id = PasswordResetService.validate_password_reset_token(password_reset_token)
      return { error: 'Invalid token' } unless user_id

      user = User.find_by(id: user_id)
      return { error: 'User not found' } unless user

      hashed_password = BCrypt::Password.create(new_password)
      user.update(password_hash: hashed_password)

      password_reset_token_record = PasswordResetToken.find_by(token: password_reset_token)
      password_reset_token_record.update(used: true) if password_reset_token_record

      { success: 'Password updated successfully' }
    end
  end
end

