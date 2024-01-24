
class User < ApplicationRecord
  # validations
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_format_of :email, with: EMAIL_REGEX, message: I18n.t('activerecord.errors.messages.invalid')

  # end for validations

  class << self
  end
end
