class UserMailer < ApplicationMailer
  def send_confirmation_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Confirmation Instructions')
  end
end


