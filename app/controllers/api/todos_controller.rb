class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion update]
  before_action :authenticate_user!, only: [:index]
  before_action :set_folder, only: [:index]
  before_action :set_todo, only: [:update]

  def index
    todos = @folder.todos.select(:id, :title, :description, :due_date, :priority, :status)
    render json: todos, status: :ok
  end

  def create
    @todo = TodoService::Create.new(create_params, current_resource_owner).execute
    if @todo
      render :show, status: :created
    else
      render json: { error: 'Failed to create todo' }, status: :unprocessable_entity
    end
  end

  def destroy
    @todo = TodoService::ValidateTodo.new(params[:id], current_resource_owner.id).execute
    if @todo
      message = TodoService::Delete.new(params[:id], current_resource_owner.id).execute
      render json: { status: 200, message: message }, status: :ok
    else
      render json: { error: 'This to-do item is not found' }, status: :unprocessable_entity
    end
  end

  def cancel_deletion
    result = TodoService::CancelDeletion.new(params[:id], current_resource_owner.id).execute
    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: { status: 200, message: result[:message] }, status: :ok
    end
  end

  def update
    if @todo.update(update_params)
      render json: { status: 200, todo: @todo.as_json.merge(updated_at: Time.zone.now) }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user!
    @current_user = UserService::SignIn.execute(session_or_token)
    render json: { error: 'Not Authenticated' }, status: :unauthorized unless @current_user
  end

  def set_folder
    @folder = Folder.find_by(id: params[:folder_id], user_id: @current_user.id)
    unless @folder
      render json: { error: 'Folder not found or not owned by user' }, status: :not_found
    end
  end

  def set_todo
    @todo = current_resource_owner.todos.find_by(id: params[:id])
    render json: { error: 'Todo item not found.' }, status: :not_found unless @todo
  end

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end

  def update_params
    params.require(:todo).permit(:title, :description, :due_date, :priority, :status).tap do |whitelisted|
      validate_update_params!(whitelisted)
    end
  end

  def validate_update_params!(params)
    errors = []
    errors << 'Invalid ID format.' unless params[:id].to_i.to_s == params[:id].to_s
    errors << 'The title cannot exceed 200 characters.' if params[:title].length > 200
    errors << 'The description cannot exceed 1000 characters.' if params[:description].length > 1000
    errors << 'Invalid due date format.' unless params[:due_date].is_a?(DateTime)
    errors << 'Invalid priority format.' unless params[:priority].to_i.to_s == params[:priority].to_s
    errors << 'Invalid status format.' unless params[:status].to_i.to_s == params[:status].to_s
    render json: { errors: errors }, status: :unprocessable_entity if errors.any?
  end
end
