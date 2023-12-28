class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion index update]
  before_action :set_todo, only: %i[update destroy]

  def index
    if folder_exists?(params[:folder_id])
      todos = Todo.where(folder_id: params[:folder_id])
      render json: todos.as_json(only: %i[id title description status created_at updated_at]), status: :ok
    else
      render json: { error: 'Folder not found' }, status: :not_found
    end
  end

  def create
    if todo_params[:title].blank?
      render json: { error: 'The title is required.' }, status: :bad_request
    elsif !folder_exists?(todo_params[:folder_id])
      render json: { error: 'Folder not found.' }, status: :unprocessable_entity
    else
      @todo = TodoService::Create.new(todo_params, current_resource_owner).execute
      if @todo.persisted?
        render json: { status: 201, todo: @todo.as_json(only: %i[id title description folder_id created_at]) }, status: :created
      else
        render json: { error: 'Failed to create todo' }, status: :unprocessable_entity
      end
    end
  end

  def update
    if @todo.nil?
      render json: { error: 'Todo not found' }, status: :not_found
      return
    end

    unless params[:id].to_s.match?(/\A\d+\z/)
      render json: { error: 'Wrong format.' }, status: :bad_request
      return
    end

    if update_params[:title].blank?
      render json: { error: 'The title is required.' }, status: :unprocessable_entity
      return
    elsif update_params[:title].length > 200
      render json: { error: 'You cannot input more than 200 characters.' }, status: :unprocessable_entity
      return
    end

    if update_params[:description].length > 1000
      render json: { error: 'You cannot input more than 1000 characters.' }, status: :unprocessable_entity
      return
    end

    if @todo.update(update_params)
      render :show, status: :ok
    else
      render json: { error: 'Failed to update todo' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Todo not found' }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    if @todo
      if @todo.destroy
        render json: { message: 'Todo successfully deleted' }, status: :ok
      else
        render json: { error: 'Failed to delete todo' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Todo not found' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
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

  def set_todo
    @todo = Todo.find_by(id: params[:id], user_id: current_resource_owner.id)
    render json: { error: 'Todo not found' }, status: :not_found if @todo.nil?
  end

  def folder_exists?(folder_id)
    Folder.exists?(folder_id)
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :folder_id)
  end

  def create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment)
  end

  def update_params
    params.require(:todo).permit(:title, :description, :status)
  end
end
