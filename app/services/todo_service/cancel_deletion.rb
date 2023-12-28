# rubocop:disable Style/ClassAndModuleChildren
class TodoService::CancelDeletion
  attr_accessor :id, :user_id

  def initialize(id, user_id)
    @id = id
    @user_id = user_id
  end

  def execute(folder_id = nil)
    # Validate user
    user_exists = UserService::ValidateUser.new(user_id).execute
    return { error: 'User does not exist' } unless user_exists

    if folder_id
      # Find the folder and validate ownership
      folder = Folder.find_by(id: folder_id, user_id: user_id)
      return { error: 'Folder does not exist or does not belong to the user' } unless folder

      # Start a transaction to ensure all or nothing is applied
      ActiveRecord::Base.transaction do
        # Find todos with a deleted_at timestamp within the folder
        todos_to_restore = folder.todos.where.not(deleted_at: nil)
        
        # Check if there are any todos to restore
        return { error: 'No deleted todos in the folder to restore' } if todos_to_restore.empty?

        # Iterate over todos and cancel deletion
        todos_to_restore.each do |todo|
          todo.update!(deleted_at: nil)
          Rails.logger.info("User #{user_id} cancelled the deletion of Todo #{todo.id} in Folder #{folder_id}")
        end
      end

      # Return success message
      { message: 'Deletion of the todos in the folder has been successfully cancelled.' }
    else
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
  rescue ActiveRecord::RecordInvalid => e
    # Handle any exceptions that occur during the transaction
    { error: "An error occurred while cancelling the deletion: #{e.message}" }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
