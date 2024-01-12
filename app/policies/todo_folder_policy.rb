# typed: true
# frozen_string_literal: true

class TodoFolderPolicy < ApplicationPolicy
  def create?
    # Assuming that only confirmed users can create todo folders
    user.email_confirmed?
  end
end

end
