class EmailConfirmationRequest < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :requested_at, presence: true

end
