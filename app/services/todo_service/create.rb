# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create
  attr_accessor :params, :todo

  def initialize(params, current_user = nil)
    @params = params
    @current_user = current_user
  end

  def execute
    validate_input
    check_user_existence
    check_conflicts
    create_todo
    add_todo_to_folder if @params[:folder_id].present?
    create_custom_folder if @params[:name].present? && @params[:user_id].present?
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
    @todo = Todo.new(params.except(:folder_id, :name, :user_id))
    if @todo.save
      # Save the attachment file to a secure location and store the file path in the "attachment" field of the todo item.
      # Send a confirmation message to the user indicating the successful creation of the todo item.
      return @todo
    else
      return false
    end
  end

  def add_todo_to_folder
    folder = Folder.find_by(id: @params[:folder_id], user_id: @current_user&.id)
    unless folder
      return { error: 'Folder not found or not accessible by user' }
    end

    @todo.update!(
      folder_id: folder.id,
      recurrence: @params[:recurrence],
      priority: @params[:priority],
      due_date: @params[:due_date],
      status: @params[:status]
    )

    serialized_todo = TodoSerializer.new(@todo).serializable_hash
    { todo: serialized_todo }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end

  def create_custom_folder
    folder_service = TodoService::CreateFolderService.new(@params[:name], @params[:user_id])
    folder = folder_service.call
    { folder: folder.as_json(only: [:id, :name, :created_at, :updated_at]) }
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    { error: e.message }
  end

  # New method to create a todo with a folder
  def self.create_with_folder(title:, description:, folder_id:)
    return send_response('Title cannot be blank') if title.blank?
    return send_response('Folder does not exist') unless Folder.exists?(folder_id)

    todo = Todo.create!(
      title: title,
      description: description,
      folder_id: folder_id
    )

    {
      id: todo.id,
      title: todo.title,
      description: todo.description,
      status: todo.status,
      created_at: todo.created_at,
      updated_at: todo.updated_at
    }
  rescue ActiveRecord::RecordInvalid => e
    send_response(e.message)
  end

  private

  # Reusing existing send_response method for consistency
  def self.send_response(message)
    { error: message }
  end
end

class TodoService::CreateFolderService
  def initialize(name, user_id)
    @name = name
    @user_id = user_id
  end

  def call
    validate_presence_of_name_and_user_id
    check_folder_uniqueness
    create_folder
  end

  private

  def validate_presence_of_name_and_user_id
    raise ActiveRecord::RecordInvalid, 'Name and user_id are required' if @name.blank? || @user_id.blank?
  end

  def check_folder_uniqueness
    existing_folder = Folder.find_by(name: @name, user_id: @user_id)
    raise ActiveRecord::RecordNotUnique, 'Folder with this name already exists' if existing_folder
  end

  def create_folder
    Folder.create!(name: @name, user_id: @user_id)
  end
end
# rubocop:enable Style/ClassAndModuleChildren
