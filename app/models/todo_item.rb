class TodoItem < ApplicationRecord
  # validations
  validates :title, presence: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :todo_folder_id, presence: true
  # end for validations

  # associations
  belongs_to :todo_folder
  # end for associations

  class << self
  end
end
