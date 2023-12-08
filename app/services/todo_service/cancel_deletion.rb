# rubocop:disable Style/ClassAndModuleChildren
class TodoService::CancelDeletion
  attr_accessor :id, :user_id
  def initialize(id, user_id)
    @id = id
    @user_id = user_id
  end
  def execute
    # Validate user
    user_exists = UserService::ValidateUser.new(user_id).execute
    return { error: 'User does not exist' } unless user_exists
    # Validate todo
    todo_exists = TodoService::ValidateTodo.new(id, user_id).execute
    return { error: 'Todo does not exist or does not belong to the user' } unless todo_exists
    # Cancel deletion
    todo = Todo.find(id)
    todo.update(deleted_at: nil)
    # Log the cancellation action
    Rails.logger.info("User #{user_id} cancelled the deletion of Todo #{id}")
    # Return success message
    { message: 'Deletion of the to-do item has been successfully cancelled.' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
