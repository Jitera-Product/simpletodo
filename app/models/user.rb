class User < ApplicationRecord
  has_one :dashboard, dependent: :destroy
  has_one :email_confirmation, dependent: :destroy

  has_many :password_reset_tokens, dependent: :destroy
  has_many :email_confirmation_requests, dependent: :destroy
  has_many :todos, dependent: :destroy
  has_many :authentication_tokens, dependent: :destroy
  has_many :dashboards, dependent: :destroy
  has_many :email_confirmations, dependent: :destroy
  has_many :comments, dependent: :destroy

  # validations
  validates_presence_of :name, :email, :password_hash
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email_confirmed, inclusion: { in: [true, false] }
  # end for validations

  class << self
    def email_registered_and_unconfirmed?(email)
      user = find_by(email: email)
      user.present? && !user.email_confirmed
    end
  end
end
