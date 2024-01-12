# typed: true
# frozen_string_literal: true

class TodoFolderPolicy < ApplicationPolicy
  def create?
    # Ensure the user has the necessary permissions to create a todo folder
    return false unless user.present?

    # Additional permission checks can be implemented here

    !user.nil?
  end

  def destroy?
    # Check if the user is not nil and if the folder belongs to the user
    !user.nil? && record.user_id == user.id
  end

  # Additional methods and logic can be added here as needed.
end
