class Todo < ApplicationRecord
  # associations
  belongs_to :user
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
  validates :is_recurring, inclusion: { in: [true, false] }
  validates :recurring_type, presence: true, if: :is_recurring?
  # custom methods
  def is_recurring?
    is_recurring
  end
  # scopes
  scope :overdue, -> { where('due_date < ?', Time.now) }
  scope :due_today, -> { where('due_date = ?', Date.today) }
  scope :upcoming, -> { where('due_date > ?', Date.today) }
  # callbacks
  # Define any callbacks like before_save, after_create, etc here
  # end for validations
  class << self
    # Define class methods here
  end
end
