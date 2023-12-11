# /app/services/email_validation_service/handler.rb

require_relative 'validator'

module EmailValidationService
  class Handler
    def self.handle_invalid_email(email)
      unless Validator.validate_email_format(email)
        return "Error: The email address provided is invalid. Please enter a valid email address."
      end

      nil # or return a success message if the system requires it
    end
  end
end
