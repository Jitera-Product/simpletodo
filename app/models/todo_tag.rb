class TodoTag < ApplicationRecord
  # relationships
  belongs_to :todo
  belongs_to :tag

  # validations
  validates :name, presence: true
  validates :todo_id, presence: true
  validates :tag_id, presence: true

  # custom methods
end
