# frozen_string_literal: true

module UserService
  class SendConfirmationEmail
    def initialize(user_email, confirmation_token)
      @user_email = user_email
      @confirmation_token = confirmation_token
    end

    def execute
      UserMailer.confirmation_instructions(@user_email, @confirmation_token).deliver_now
    end
  end
end

class UserMailer < ActionMailer::Base
  def confirmation_instructions(user_email, token)
    @token = token
    mail(to: user_email, subject: 'Confirmation Instructions')
  end
end
