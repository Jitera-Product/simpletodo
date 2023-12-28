class TodoCategory < ApplicationRecord
  # relationships
  belongs_to :category
  belongs_to :todo

  # validations
  validates :name, presence: true
  validates :category_id, presence: true
  validates :todo_id, presence: true

  # custom methods
end
