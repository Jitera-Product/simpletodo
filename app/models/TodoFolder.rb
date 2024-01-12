class TodoFolder < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :user_id, presence: true
  # end for validations

  # relationships
  belongs_to :user
  # end for relationships

  class << self
  end
end
