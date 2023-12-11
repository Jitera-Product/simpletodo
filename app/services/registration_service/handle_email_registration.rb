# /app/services/registration_service/handle_email_registration.rb

class RegistrationService::HandleEmailRegistration
  def self.execute(email)
    if RegistrationService::CheckEmail.email_already_registered?(email)
      return { error: 'Email address is already in use.' }
    end

    # No action needed if the email is not registered
  end
end
