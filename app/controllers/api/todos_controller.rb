class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion attach_file validate]

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

  def attach_file
    todo = Todo.find_by(id: params[:id])
    return render json: { error: 'The todo item does not exist.' }, status: :not_found unless todo
    return render json: { error: 'Please provide a valid file.' }, status: :unprocessable_entity unless params[:file].present? && params[:file].is_a?(ActionDispatch::Http::UploadedFile)

    result = TodoService::AttachFile.new(todo, attach_file_params, current_resource_owner).execute

    if result[:error]
      render json: { error: result[:error] }, status: result[:status]
    else
      render json: { status: 201, attachment: result[:attachment] }, status: :created
    end
  end

  def validate
    validation_service = TodoService::ValidateDetails.new(validate_params.merge(user_id: current_resource_owner.id))
    result = validation_service.execute
    if result[:message] == 'Details are valid'
      render json: { status: 200, message: result[:message] }, status: :ok
    else
      render json: { error: result[:message] }, status: :conflict
    end
  end

  private

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end

  def attach_file_params
    params.permit(:file)
  end

  def validate_params
    params.permit(:title, :due_date)
  end
end
