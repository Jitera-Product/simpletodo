class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion associate_categories validate_due_date]
  before_action :set_todo, only: %i[associate_categories]
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
  def associate_categories
    category_ids = params[:category_ids]
    if category_ids.blank? || !Category.where(id: category_ids).exists?
      render json: { error: 'One or more categories not found' }, status: :bad_request
      return
    end
    begin
      TodoCategoryAssociator.new(@todo, category_ids).execute
      render json: { status: 200, todo: { id: @todo.id, categories: @todo.categories } }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end
  def validate_due_date
    begin
      due_date = DateTime.parse(params[:due_date])
      if due_date > DateTime.now
        render json: { status: 200, message: 'The due date is valid.' }, status: :ok
      else
        render json: { error: 'Due date must be in the future.' }, status: :unprocessable_entity
      end
    rescue ArgumentError
      render json: { error: 'Invalid date format.' }, status: :bad_request
    end
  end
  private
  def set_todo
    @todo = Todo.find_by(id: params[:todo_id])
    render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end
  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end
end
