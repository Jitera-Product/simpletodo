class Folder < ApplicationRecord
  # relationships
  belongs_to :user
  has_many :todos, dependent: :destroy

  # validations
  validates :name, presence: true
  validates :user_id, presence: true

  # custom methods
end
