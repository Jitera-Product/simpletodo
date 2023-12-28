class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion index]
  
  def index
    if folder_exists?(params[:folder_id])
      todos = Todo.where(folder_id: params[:folder_id])
      render json: todos.as_json(only: %i[id title description status created_at updated_at]), status: :ok
    else
      render json: { error: 'Folder not found' }, status: :not_found
    end
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
      begin
        message = TodoService::Delete.new(params[:id], current_resource_owner.id).execute
        render json: { status: 200, message: message }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    else
      render json: { error: 'Todo item not found or does not belong to the user' }, status: :not_found
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

  def folder_exists?(folder_id)
    Folder.exists?(folder_id)
  end

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
