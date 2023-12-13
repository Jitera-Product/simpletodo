class Todo < ApplicationRecord
  has_many :todo_categories, dependent: :destroy
  has_many :todo_tags, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy # New relationship added

  belongs_to :user

  enum priority: { low: 0, medium: 1, high: 2 }, _suffix: true
  enum recurrence: { none: 0, daily: 1, weekly: 2, monthly: 3 }, _suffix: true
  enum status: { active: 0, completed: 1, deleted: 2 }, _suffix: true

  # validations
  validates :title, presence: true
  validates :priority, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :description, presence: true
  validates :user_id, presence: true
  # end for validations

  class << self
  end
end
