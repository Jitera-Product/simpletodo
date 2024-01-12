
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::CancelDeletion
  attr_accessor :id, :user_id
  def initialize(id, user_id)
    @id = id
    @user_id = user_id
  end
  def execute
    # Validate user
    user_exists = User.exists?(user_id)
    return { error: 'User does not exist' } unless user_exists
    # Validate todo
    todo_exists = TodoService::ValidateTodo.new(id, user_id).execute
    return { error: 'Todo does not exist or does not belong to the user' } unless todo_exists
    # Abort folder creation process without database alterations
    # Log the cancellation action
    Rails.logger.info("User #{user_id} has aborted the folder creation process.")
    # Return success message
    { message: 'Folder creation process has been successfully aborted.' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
