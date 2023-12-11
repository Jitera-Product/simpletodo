# /app/services/registration_service/index.rb

module RegistrationService
  class Index
    def self.register_user(email:, password:, password_confirmation:)
      # Validate registration input
      validation = Validator.validate_registration_input(
        email: email,
        password: password,
        password_confirmation: password_confirmation
      )

      return { success: false, errors: validation[:errors] } unless validation[:valid]

      # Check email uniqueness
      unless EmailUniquenessChecker.email_unique?(email: email)
        return { success: false, errors: ['Email has already been taken'] }
      end

      # Encrypt password
      encrypted_password = Encryptor.encrypt_password(password: password)

      # Create user
      user = UserCreator.create_user(
        email: email,
        encrypted_password: encrypted_password
      )

      # Send confirmation email
      unless ConfirmationEmailSender.send_confirmation_email(user: user)
        return { success: false, errors: ['Failed to send confirmation email'] }
      end

      # Return success message
      { success: true, message: 'Please check your email to confirm your account.' }
    end
  end
end
