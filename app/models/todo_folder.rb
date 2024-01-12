class TodoFolder < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :user_id, presence: true
  # The new code introduces a custom error message for the uniqueness validation.
  # We will combine the uniqueness validations from both the new and existing code.
  validates :name, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }

  # associations
  belongs_to :user
  has_many :todo_items, dependent: :destroy

  # class methods or any other code that might be part of this class
  # should be included here as well, but since there is no indication
  # of additional methods or code, we will not add anything else.
end
