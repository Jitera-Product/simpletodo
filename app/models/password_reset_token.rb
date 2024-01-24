class PasswordResetToken < ApplicationRecord
  belongs_to :user

  validates :password_reset_token, :user_id, presence: true
  validates :password_reset_token, uniqueness: true

  scope :valid, -> { where('created_at >= ?', 24.hours.ago) }

  # Additional methods and validations can be added here
end
