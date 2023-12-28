class Todo < ApplicationRecord
  # validations
  validates :title, presence: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :priority, presence: true
  validates :status, presence: true
  validates :recurrence, presence: true # Assuming recurrence is a required field
  # end for validations

  # relationships
  belongs_to :folder
  has_many :attachments, dependent: :destroy
  has_many :todo_categories, dependent: :destroy
  has_many :todo_tags, dependent: :destroy
  # end for relationships

  # custom methods
  # end for custom methods

  class << self
    # class methods
  end
  # end for class methods
end
