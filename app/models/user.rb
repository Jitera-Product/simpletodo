class User < ApplicationRecord
  # validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: EMAIL_REGEX, message: I18n.t('activerecord.errors.messages.invalid')
  # end validations

  # associations
  has_many :password_reset_tokens
  has_many :authentication_tokens
  # end associations

  # instance methods

  def generate_auth_token
    token = SecureRandom.hex
    authentication_tokens.create!(
      token: token,
      expires_at: 24.hours.from_now
    )
    token
  end

  def invalidate_reset_token
    self.password_reset_tokens.valid.destroy_all
  end

  def generate_confirmation_token_and_update
    self.confirmation_token = SecureRandom.urlsafe_base64
    self.confirmation_token_created_at = Time.current
    save
  end

  def generate_password_reset_token
    token = SecureRandom.hex(10)
    password_reset_token = self.password_reset_tokens.create(token: token, created_at: Time.current)
    if password_reset_token.persisted?
      token
    else
      nil
    end
  end

  # end instance methods

  class << self
    # class methods can be added here
  end

  # Other model methods...

  private
  # private methods can be added here
end
