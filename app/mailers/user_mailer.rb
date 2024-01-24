class UserMailer < ApplicationMailer
  # existing methods...

  def send_confirmation_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Confirmation Instructions')
  end

  def reset_password_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Reset password instructions')
  end
end
