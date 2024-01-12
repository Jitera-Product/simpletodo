class User < ApplicationRecord
  # validations
  validates :username, presence: true, uniqueness: true
  # The email validation format is updated to use URI::MailTo::EMAIL_REGEXP for better accuracy.
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_hash, presence: true
  validates :confirmation_token, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email_confirmed, inclusion: { in: [true, false] }
  validates :confirmation_token_created_at, presence: true

  # end for validations

  # associations
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :todo_folders, dependent: :destroy
  # end for associations

  # custom instance methods
  def update_password_hash(new_password_hash)
    update(password_hash: new_password_hash)
  end

  # The existing code does not have custom class methods or scopes defined,
  # so we keep this section empty as it was in the new code.
  class << self
    # custom methods or scopes
  end

  # custom instance methods
  # No additional instance methods in the existing code, so nothing to merge here.
end
