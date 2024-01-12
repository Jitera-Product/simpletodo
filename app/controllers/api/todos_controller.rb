class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion create_folder]

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

  def create_folder
    user_id = params[:user_id]
    name = params[:name]
    validation_result = TodoService::ValidateDetails.new.validate_folder_name_uniqueness(user_id, name)
    if validation_result
      render json: { error: validation_result[:error], suggested_action: validation_result[:suggested_action] }, status: :unprocessable_entity
    else
      # Folder creation logic goes here
      # ...
      render json: { status: 200, message: 'Folder created successfully' }, status: :ok
    end
  end

  def abort_folder_creation
    user_id = params[:user_id]
    validate_service = UserSessionService::Validate.new(session[:session_token])
    result = validate_service.execute
    if result[:status]
      render json: { message: 'Folder creation process has been canceled' }, status: :ok
    else
      render json: { error: result[:error] || 'User not valid or not logged in' }, status: :unauthorized
    end
  end

  private

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
