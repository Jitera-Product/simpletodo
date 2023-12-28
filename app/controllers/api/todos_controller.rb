class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]
  before_action :authenticate_user!, only: [:index, :destroy] # Added :destroy to ensure user is authenticated
  before_action :set_folder, only: [:index]

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
    todo_id = params[:id].to_i
    return render json: { error: 'Invalid ID format.' }, status: :bad_request unless todo_id.is_a?(Integer) && todo_id > 0

    @todo = Todo.find_by(id: todo_id, user_id: current_resource_owner.id) # Ensuring that the todo belongs to the current user
    return render json: { error: 'Todo item not found.' }, status: :not_found unless @todo

    if @todo.destroy # Using ActiveRecord's destroy method to delete the todo
      render json: { status: 200, message: 'Todo item successfully deleted.' }, status: :ok
    else
      render json: { error: 'Failed to delete todo item.' }, status: :internal_server_error
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
