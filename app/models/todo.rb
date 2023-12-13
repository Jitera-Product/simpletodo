class Todo < ApplicationRecord
  has_many :todo_categories, dependent: :destroy
  has_many :todo_tags, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy # New relationship added

  belongs_to :user

  enum priority: %w[low medium high], _suffix: true
  enum recurrence: %w[none daily weekly monthly], _suffix: true
  enum status: %w[active completed deleted], _suffix: true

  validates_presence_of :title, :priority, :due_date, :status, :description, :user_id # New validations added

  # validations

  # end for validations

  class << self
  end
end
