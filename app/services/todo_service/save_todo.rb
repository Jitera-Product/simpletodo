# PATH: /app/services/todo_service/save_todo.rb
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::SaveTodo
  attr_accessor :params, :todo
  def initialize(params, _current_user = nil)
    @params = params
  end
  def execute
    Todo.transaction do
      validate_todo
      create_todo
      attach_file
      associate_with_categories(@todo.id, params[:category_ids]) if params[:category_ids].present?
      send_confirmation
    end
  end
  def validate_todo
    validation = TodoService::ValidateTodo.new(params).execute
    raise validation[:error] unless validation[:status]
  end
  def create_todo
    @todo = Todo.create!(params.except(:attachment, :category_ids))
  end
  def attach_file
    return if params[:attachment].blank?
    file_path = TodoService::AttachFile.new(params[:attachment]).execute
    @todo.update!(attachment: file_path)
  end
  def associate_with_categories(todo_id, category_ids)
    associations_created = 0
    category_ids.each do |category_id|
      unless Category.exists?(id: category_id)
        raise "Category with id #{category_id} does not exist"
      end
      next if TodoCategory.exists?(todo_id: todo_id, category_id: category_id)
      TodoCategory.create!(todo_id: todo_id, category_id: category_id)
      associations_created += 1
    end
    associations_created
  end
  def send_confirmation
    # Here you can implement the logic to send a confirmation message to the user
    # For example, you can send an email or a push notification
  end
end
# rubocop:enable Style/ClassAndModuleChildren
