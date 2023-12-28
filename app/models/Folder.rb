class Folder < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :user_id, presence: true
  # end for validations

  # relationships
  belongs_to :user
  has_many :todos
  # end for relationships

  class << self
  end
end
