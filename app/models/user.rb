class User < ApplicationRecord
  # validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: EMAIL_REGEX, message: I18n.t('activerecord.errors.messages.invalid')

  # associations
  has_many :password_reset_tokens
  has_many :authentication_tokens # Assuming this association is needed for the new code
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

  # end instance methods

  class << self
    # class methods can be added here
  end
end
