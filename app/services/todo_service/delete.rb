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
# rubocop:enable Style/ClassAndModuleChildren
