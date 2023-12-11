# /app/services/registration_service/check_email_availability.rb
# rubocop:disable Style/ClassAndModuleChildren
module RegistrationService
  class CheckEmailAvailability
    attr_reader :email

    def initialize(email)
      @email = email
    end

    def call
      if User.exists?(email: email)
        { message: 'Email address is already in use.' }
      else
        { message: 'Email address is available.' }
      end
    rescue StandardError => e
      # Log the error and return a generic error message
      Rails.logger.error("CheckEmailAvailability: #{e.message}")
      { message: 'An error occurred while checking the email availability.' }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
