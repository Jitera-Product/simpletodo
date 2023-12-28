class Attachment < ApplicationRecord
  # relationships
  belongs_to :todo

  # validations
  validates :file_path, presence: true
  validates :todo_id, presence: true

  # custom methods
  # end for custom methods
end
