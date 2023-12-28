class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]

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
        TodoService::Delete.new(params[:id], current_resource_owner.id).execute
        render json: { status: 200, message: "Todo item with id #{params[:id]} has been successfully deleted." }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    else
      render json: { error: 'Todo item not found or does not belong to the user', status: 404 }, status: :not_found
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

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
