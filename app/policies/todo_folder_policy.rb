# typed: true
# frozen_string_literal: true

class TodoFolderPolicy < ApplicationPolicy
  def create?
    !user.nil?
  end
end

# Additional methods and logic can be added here as needed.

