class User < ApplicationRecord
  # validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  # end for validations

  # relationships
  # Assuming that other models such as Folder or any other that has a relationship with User already exist
  # Add any new relationships below if any new tables are related to the User model
  # end for relationships

  # custom methods
  # Define any custom methods that you need for the User model here
  # end for custom methods
end
