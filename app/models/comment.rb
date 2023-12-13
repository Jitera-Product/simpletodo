class Comment < ApplicationRecord
  # Associations
  belongs_to :todo
  belongs_to :user

  # Validations
  validates :content, presence: true
  validates :todo_id, presence: true
  validates :user_id, presence: true

  # Custom logic (if any)
end
