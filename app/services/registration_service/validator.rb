# /app/services/registration_service/validator.rb

module RegistrationService
  class Validator
    def self.validate_registration_input(email:, password:, password_confirmation:)
      errors = []

      errors << 'Email cannot be blank' if email.blank?
      errors << 'Invalid email format' unless email.match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      errors << 'Password cannot be blank' if password.blank?
      errors << 'Password confirmation cannot be blank' if password_confirmation.blank?
      errors << 'Passwords do not match' unless password == password_confirmation

      { valid: errors.empty?, errors: errors }
    end
  end
end
