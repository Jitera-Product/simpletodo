class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]
  before_action :authenticate_user!, only: [:index, :list_in_folder]
  before_action :set_folder, only: [:index, :list_in_folder]

  def index
    todos = @folder.todos.select(:id, :title, :description, :due_date, :priority, :status)
    render json: todos, status: :ok
  end

  def list_in_folder
    if @folder
      todos = @folder.todos.select(:id, :title, :description, :due_date, :priority, :status, :created_at, :folder_id)
      render json: { status: 200, todos: todos }, status: :ok
    else
      render json: { error: 'Folder not found.' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
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

  private

  def authenticate_user!
    # Assuming UserService::SignIn#execute exists and returns the user if authenticated
    @current_user = UserService::SignIn.execute(session_or_token)
    render json: { error: 'Not Authenticated' }, status: :unauthorized unless @current_user
  end

  def set_folder
    @folder = Folder.find_by(id: params[:folder_id], user_id: @current_user.id)
    unless @folder
      render json: { error: 'Folder not found or not owned by user' }, status: :not_found
    end
  end

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
