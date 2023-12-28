class User < ApplicationRecord
  # relationships
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :folders, dependent: :destroy
  # end for relationships

  # validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  # end for validations

  # custom methods
  # end for custom methods

  class << self
    # custom class methods
  end
  # end for custom class methods
end
