# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create
  attr_accessor :params, :todo
  def initialize(params, _current_user = nil)
    @params = params
  end
  def execute
    validate_input
    check_user_existence
    check_conflicts
    create_todo
  end
  def validate_input
    TodoService::ValidateInput.new(params).execute
  end
  def check_user_existence
    TodoService::CheckUserExistence.new(params[:user_id]).execute
  end
  def check_conflicts
    TodoService::CheckConflicts.new(params).execute
  end
  def create_todo
    @todo = Todo.new(params)
    if @todo.save
      # Save the attachment file to a secure location and store the file path in the "attachment" field of the todo item.
      # Send a confirmation message to the user indicating the successful creation of the todo item.
      return @todo
    else
      return false
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
