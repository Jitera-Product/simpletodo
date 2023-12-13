class Comment < ApplicationRecord
  # relationships
  belongs_to :todo
  belongs_to :user

  # validations
  validates_presence_of :text, :todo_id, :user_id

  # end for validations
end
