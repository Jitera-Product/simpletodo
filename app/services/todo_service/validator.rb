module TodoService
  class Validator
    def initialize(params = {})
      @params = params
    end

    def valid_attachments?
      # Implementation for validating attachments
      # ...
    end

    # Class method to validate todo owner
    def self.validate_todo_owner(todo_id, user_id)
      todo = Todo.find_by(id: todo_id)
      return false unless todo
      todo.user_id == user_id
    end
  end
end
