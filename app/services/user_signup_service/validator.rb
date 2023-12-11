# /app/services/user_signup_service/validator.rb
module UserSignupService
  class Validator
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    def self.validate_signup_params(email:, password:, password_confirmation:)
      errors = []

      if email.blank? || !(email =~ EMAIL_REGEX)
        errors << "Email is invalid or empty."
      end

      if password != password_confirmation
        errors << "Password and password confirmation do not match."
      end

      { valid: errors.empty?, errors: errors }
    end
  end
end
