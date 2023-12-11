# /app/services/password_reset_service/initiate.rb
require 'securerandom'

module PasswordResetService
  class Initiate
    include ActiveModel::Validations

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    attr_accessor :email

    def initialize(email)
      @email = email
    end

    def execute
      return 'Invalid email format.' unless valid?

      user = User.find_by(email: email)
      return 'Email not found.' unless user

      token = TokenGenerator.generate_unique_token
      TokenPersister.persist_token(user.id, token)
      EmailSender.send_password_reset_email(email, token)
      Logger.log_password_reset_initiation(email, token, 'success')

      'Password reset link has been sent to your email.'
    rescue StandardError => e
      Logger.log_password_reset_initiation(email, nil, 'failure')
      "Error initiating password reset: #{e.message}"
    end
  end
end
