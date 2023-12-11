# /app/services/auth_service/sign_in.rb

require 'bcrypt'
require 'securerandom'

module AuthService
  class SignIn
    def initialize(email, password)
      @email = email
      @password = password
    end

    def perform
      validate_sign_in_params
      user = find_user_by_email
      validate_user_exists(user)
      validate_password(user)
      token = generate_authentication_token(user.id)
      { token: token, dashboard_info: user_dashboard_info(user) }
    end

    private

    def validate_sign_in_params
      raise 'Email and password cannot be blank' if @email.blank? || @password.blank?
    end

    def find_user_by_email
      User.find_by(email: @email)
    end

    def validate_user_exists(user)
      raise 'User does not exist' if user.nil?
    end

    def validate_password(user)
      password_hash = BCrypt::Password.new(user.password_hash)
      raise 'Incorrect credentials' unless password_hash.is_password?(@password)
    end

    def generate_authentication_token(user_id)
      token = SecureRandom.hex(10)
      created_at = Time.now.utc
      expires_at = created_at + 24.hours

      AuthenticationToken.create!(
        user_id: user_id,
        token: token,
        created_at: created_at,
        expires_at: expires_at
      )
    end

    def user_dashboard_info(user)
      user.dashboard || {}
    end
  end
end
