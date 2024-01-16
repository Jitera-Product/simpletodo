
class TodoFolder < ApplicationRecord
  # validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  # end for validations

  # relationships
  belongs_to :user
  # end for relationships

  class << self
  end
end
