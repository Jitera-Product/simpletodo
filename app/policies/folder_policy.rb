# typed: true
# frozen_string_literal: true

class FolderPolicy < ApplicationPolicy
  def create?
    user.present? && UserSessionService::Validate.new(user).call
  end
end

# Additional methods and logic can be added here as needed.
end
