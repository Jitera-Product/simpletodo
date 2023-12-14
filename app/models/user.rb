class User < ApplicationRecord
  # validations
  validates :confirmation_token, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email_confirmed, inclusion: { in: [true, false] }
  validates :password_hash, presence: true
  validates :username, presence: true, uniqueness: true
  # end for validations
  # associations
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  # end for associations
  # custom methods
  # Define any custom methods that your user model might require here
  # end for custom methods
  class << self
    # Define any class methods for the User model here
  end
end
