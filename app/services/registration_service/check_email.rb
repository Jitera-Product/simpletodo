# /app/services/registration_service/check_email.rb

class RegistrationService::CheckEmail
  def self.email_already_registered?(email)
    User.exists?(email: email)
  end
end
