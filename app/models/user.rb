class User < ApplicationRecord
  # validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: EMAIL_REGEX, message: I18n.t('activerecord.errors.messages.invalid')
  # end for validations

  # associations
  has_many :password_reset_tokens
  # end associations

  def invalidate_reset_token
    self.password_reset_tokens.valid.destroy_all
  end

  class << self
  end
end
