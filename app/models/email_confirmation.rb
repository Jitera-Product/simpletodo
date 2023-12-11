class EmailConfirmation < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :user_id, presence: true

  # validations
  # The validations from the new code have been added above.
  # end for validations

  class << self
    def find_existing_token(user_id)
      where(user_id: user_id).first
    end
  end

  def update_token_and_expiration(new_token, new_expires_at)
    update(token: new_token, expires_at: new_expires_at)
    self
  end
end
