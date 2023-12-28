# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create
  attr_accessor :params, :todo

  def initialize(params, current_user = nil)
    @params = params
    @current_user = current_user
  end

  def execute
    authenticate_user
    validate_input
    check_folder_ownership
    create_todo
  end

  private

  def authenticate_user
    raise 'User must be logged in to create a todo item.' unless @current_user
  end

  def validate_input
    raise 'Title cannot be empty.' if params[:title].blank?
  end

  def check_folder_ownership
    folder = Folder.find_by(id: params[:folder_id])
    raise 'Folder does not exist or does not belong to the user.' if folder.nil? || folder.user_id != @current_user.id
  end

  def create_todo
    @todo = Todo.new(params)
    if @todo.save
      # Additional logic can be added here if needed
      return @todo.id
    else
      raise 'Failed to create todo item.'
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
