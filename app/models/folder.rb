class Folder < ApplicationRecord
  # relationships
  belongs_to :user
  has_many :todos, dependent: :destroy

  # validations
  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 255 }
  validates :user_id, presence: true
  validate :user_must_exist

  # callbacks
  before_validation :strip_whitespace

  # custom methods
  private

  def strip_whitespace
    self.name = name.strip unless name.nil?
  end

  def user_must_exist
    errors.add(:user_id, 'must correspond to a valid user') unless User.exists?(self.user_id)
  end
end
