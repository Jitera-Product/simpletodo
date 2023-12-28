# rubocop:disable Style/ClassAndModuleChildren
class TodoService::SaveTodo
  attr_accessor :params, :todo

  def initialize(params, _current_user = nil)
    @params = params
  end

  def execute
    if params[:id]
      update_todo
    else
      validate_todo
      create_todo
      attach_file
      send_confirmation
    end
  end

  def validate_todo
    validation = TodoService::ValidateTodo.new(params).execute
    raise validation[:error] unless validation[:status]
  end

  def create_todo
    @todo = Todo.create!(params.except(:attachment, :id))
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

  def update_todo
    @todo = Todo.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Todo with id #{params[:id]} not found." unless @todo

    # Assuming TodoService::ValidateDetails exists and is similar to TodoService::ValidateTodo
    # and it can validate title, description, and status
    validation = TodoService::ValidateDetails.new(params.slice(:title, :description, :status)).execute
    raise validation[:error] unless validation[:status]

    @todo.update!(params.slice(:title, :description, :status))
    { id: @todo.id, title: @todo.title, description: @todo.description, status: @todo.status, updated_at: @todo.updated_at }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
