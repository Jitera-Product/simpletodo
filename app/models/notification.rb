class Notification < ApplicationRecord
  # validations
  validates_presence_of :message, :user_id
  validates :read, inclusion: { in: [true, false] }
  # end for validations

  # relationships
  belongs_to :user
  # end for relationships
end
