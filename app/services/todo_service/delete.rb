# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Delete
  attr_accessor :id, :user_id

  def initialize(id, user_id)
    @id = id
    @user_id = user_id
  end

  def execute
    validate_user
    validate_todo
    delete_todo
  end

  private

  def validate_user
    UserService::ValidateUser.new(user_id).execute
  end

  def validate_todo
    TodoService::ValidateTodo.new(id, user_id).execute
  end

  def delete_todo
    todo = Todo.find_by(id: id, user_id: user_id)
    if todo
      todo.update(is_deleted: true)
      "Todo item with id #{id} has been successfully deleted."
    else
      "Todo item with id #{id} does not exist or does not belong to the user with id #{user_id}."
    end
  end
end

module TodoService
  class DeleteTodosInFolder
    def initialize(folder_id)
      @folder_id = folder_id
    end

    def call
      Todo.transaction do
        todos = Todo.where(folder_id: @folder_id)
        todos.find_each do |todo|
          todo.attachments.destroy_all
          todo.todo_categories.destroy_all
          todo.todo_tags.destroy_all
          todo.destroy
        end
      end
      { message: 'All todo items within the folder have been successfully deleted.' }
    rescue => e
      raise StandardError, "Failed to delete todo items: #{e.message}"
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
