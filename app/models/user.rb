class User < ApplicationRecord
  # validations
  validates :confirmation_token, presence: true
  validates :name, presence: true
  validates :email_confirmed, inclusion: { in: [true, false] }
  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  # end for validations

  # relationships
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :todo_folders, dependent: :destroy
  # end for relationships

  class << self
    # custom methods or scopes
  end

  # custom instance methods
end
