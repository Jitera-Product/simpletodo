module TodoService
  class DeleteTodoItem
    attr_reader :todo_id, :user

    def initialize(todo_id, user)
      @todo_id = todo_id
      @user = user
    end

    def execute
      todo = Todo.find_by(id: todo_id)
      return { status: 404, message: 'Todo not found' } unless todo

      if todo.user == user
        todo.destroy
        { status: 200, message: 'Todo deleted successfully' }
      else
        { status: 403, message: 'Not authorized to delete this todo' }
      end
    end
  end
end
