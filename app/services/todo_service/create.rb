
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create < BaseService
  attr_reader :current_user
  attr_accessor :params, :todo

  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def execute
    validate_input
    check_user_existence
    authenticate_user
    check_conflicts
    ActiveRecord::Base.transaction do
      create_todo
    end
  end

  def validate_input
    validate_title_uniqueness
    validate_due_date
    validate_priority
    validate_status
  end

  def check_user_existence
    raise 'User does not exist' unless User.exists?(params[:user_id])
    raise 'User is not authenticated' unless current_user && current_user.id == params[:user_id]
  end

  def check_conflicts
    # Additional logic to check for due_date conflicts
  end

  def create_todo
    @todo = Todo.new(todo_params)
    associate_category_and_tags
    if @todo.save
      attach_files
      return { message: 'Todo created successfully', id: @todo.id }
    else
      raise 'Failed to create todo'
    end
  end

  private

  def validate_title_uniqueness
    # Logic to validate title uniqueness
  end

  def validate_due_date
    # Logic to ensure due_date is in the future and does not conflict with existing todos
  end

  # Additional validation methods for priority, status, recurrence, category_id, tag_ids, and attachments
  def validate_priority
    # Logic to ensure priority is within allowed range
  end

  def validate_status
    # Logic to ensure status is within allowed range
  end

  # Methods to handle validation and association for recurrence, category_id, tag_ids, and attachments
  def associate_category_and_tags
    # Logic to associate category and tags with the todo item
  end

  def attach_files
    # Logic to handle file attachments
  end

  # Method to authenticate the user
  def authenticate_user
    # Logic to authenticate the user
  end

  def todo_params
    params.permit(:title, :due_date, :priority, :status, :recurrence, :description, :user_id)
  end

  # Additional methods as needed for the service
end
# rubocop:enable Style/ClassAndModuleChildren
