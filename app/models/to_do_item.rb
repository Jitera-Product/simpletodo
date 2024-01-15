class ToDoItem < ApplicationRecord
  # validations
  validates_presence_of :title, :due_date, :status, :folder_id
  # end for validations

  # relationships
  belongs_to :folder
  # end for relationships

  class << self
  end
end
