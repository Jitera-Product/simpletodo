class Folder < ApplicationRecord
  # validations
  validates_presence_of :name, :color, :icon, :user_id
  validates :name, uniqueness: { scope: :user_id, message: I18n.t('activerecord.errors.messages.taken') }
  # end for validations

  # relationships
  belongs_to :user
  has_many :to_do_items, dependent: :destroy
  # end for relationships

  class << self
    def name_unique_for_user?(name, user_id)
      !exists?(name: name, user_id: user_id)
    end
  end

  # instance methods
  def name_unique_for_user?(name, user_id)
    self.class.name_unique_for_user?(name, user_id)
  end
  # end for instance methods
end
