class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]
  before_action :authenticate_user!, only: [:destroy]
  before_action :set_todo, only: [:destroy]

  def create
    @todo = TodoService::Create.new(create_params, current_resource_owner).execute
    if @todo
      render :show, status: :created
    else
      render json: { error: 'Failed to create todo' }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo
      message = TodoService::Delete.new(@todo.id, current_resource_owner.id).execute
      render json: { status: 200, message: message }, status: :ok
    else
      render json: { error: 'This to-do item is not found' }, status: :not_found
    end
  rescue UserSessionService::NotAuthorizedError
    render json: { error: 'Not authorized to perform this action' }, status: :forbidden
  rescue => e
    render json: { error: 'Internal server error' }, status: :internal_server_error
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
    UserSessionService::Validate.new(request.headers).execute!
  end

  def set_todo
    @todo = Todo.find_by(id: params[:id], user_id: current_resource_owner.id)
  end

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
