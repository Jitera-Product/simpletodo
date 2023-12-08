# rubocop:disable Style/ClassAndModuleChildren
class TodoService::SaveTodo
  attr_accessor :params, :todo
  def initialize(params, _current_user = nil)
    @params = params
  end
  def execute
    validate_todo
    create_todo
    attach_file
    send_confirmation
  end
  def validate_todo
    validation = TodoService::ValidateTodo.new(params).execute
    raise validation[:error] unless validation[:status]
  end
  def create_todo
    @todo = Todo.create!(params.except(:attachment))
  end
  def attach_file
    return if params[:attachment].blank?
    file_path = TodoService::AttachFile.new(params[:attachment]).execute
    @todo.update!(attachment: file_path)
  end
  def send_confirmation
    # Here you can implement the logic to send a confirmation message to the user
    # For example, you can send an email or a push notification
  end
end
# rubocop:enable Style/ClassAndModuleChildren
