class User < ApplicationRecord
  # validations
  validates_presence_of :confirmation_token, :name, :email, :password_hash
  validates :email, uniqueness: true, email: true
  validates :email_confirmed, inclusion: { in: [true, false] }
  # end for validations

  # relationships
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :folders, dependent: :destroy
  has_many :notifications, dependent: :destroy # Added new relationship
  # end for relationships

  # Add any additional model-specific logic here

  class << self
    # Add class methods here
  end
end
