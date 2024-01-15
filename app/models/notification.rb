
class Notification < ApplicationRecord
  # validations
  validates_presence_of :message, :user_id
  validates :read, inclusion: { in: [true, false] }
  # end for validations

  # relationships
  belongs_to :user
  # end for relationships

  # scopes
  # end for scopes

  # class methods
  def self.create_for_folder_creation(user_id, folder_id)
    create(user_id: user_id, message: "Folder created successfully.", created_at: Time.current, read: false)
  end
  # end for class methods
end
