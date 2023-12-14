class Attachment < ApplicationRecord
  # associations
  belongs_to :todo, foreign_key: 'todo_id'
  # validations
  validates :file_path, presence: true
  validates :file_name, presence: true
  # custom methods
  # Define any custom methods for the Attachment model here
end
