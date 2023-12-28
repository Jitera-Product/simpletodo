class Todo < ApplicationRecord
  # relationships
  belongs_to :user
  belongs_to :folder
  has_many :attachments, dependent: :destroy
  has_many :todo_categories, dependent: :destroy
  has_many :todo_tags, dependent: :destroy

  # validations
  validates :title, presence: true
  validates :priority, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :description, presence: true
  validates :user_id, presence: true
  validates :folder_id, presence: true

  # custom methods
end
