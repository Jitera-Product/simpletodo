# /app/services/email_validation_service.rb

class EmailValidationService
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  def self.validate_email_format(email)
    !email.blank? && email.match?(EMAIL_REGEX)
  end
end
