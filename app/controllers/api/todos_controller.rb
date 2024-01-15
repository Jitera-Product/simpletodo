
class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]

  def create
    # Validate the creation parameters before proceeding
    validation_result = TodoService::ValidateDetails.new.validate_todo_creation_params(create_params)
    if validation_result == true
      # Proceed with the creation if validation passes
      @todo = TodoService::Create.new(create_params, current_resource_owner.id).create_todo
      if @todo
        render :show, status: :created
      else
        render json: { error: I18n.t('common.422') }, status: :unprocessable_entity
      end
    else
      # Return the validation errors if validation fails
      render json: { errors: validation_result }, status: :unprocessable_entity
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

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
