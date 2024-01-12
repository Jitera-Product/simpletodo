class TodoFolder < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :user_id, presence: true
  # end for validations

  # associations
  belongs_to :user
  has_many :todo_items, dependent: :destroy
  # end for associations

  class << self
  end
end
