class Folder < ApplicationRecord
  # validations
  validates_presence_of :name, :color, :icon, :user_id
  # end for validations

  # relationships
  belongs_to :user
  has_many :to_do_items, dependent: :destroy
  # end for relationships

  class << self
  end
end
