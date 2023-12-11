class Api::TodosPolicy < ApplicationPolicy
  def destroy?
    user == record.user
  end
end
