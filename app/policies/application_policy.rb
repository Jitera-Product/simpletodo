# typed: true
# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # New method to check if a user can delete folders
  def user_can_delete_folders?(user_id)
    # Retrieve the user's permissions from the database using the "user_id".
    user = User.find_by(id: user_id)
    # Check if the user has the permission to delete folders and their contents.
    user&.has_permission?(:delete_folders) || false
  rescue ActiveRecord::RecordNotFound
    # If the user is not found, we assume they do not have permission.
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
