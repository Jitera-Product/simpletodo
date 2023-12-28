class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!, only: %i[create destroy cancel_deletion]
  before_action :authenticate_user!, only: [:index, :create] # Added :create to ensure user is authenticated
  before_action :set_folder, only: [:index, :create] # Updated to include :create action

  def index
    todos = @folder.todos.select(:id, :title, :description, :due_date, :priority, :status)
    render json: todos, status: :ok
  end

  def create
    # Validate create_params before proceeding
    validator = TodoValidator.new(create_params)
    unless validator.valid?
      render json: { errors: validator.errors }, status: :unprocessable_entity and return
    end

    @todo = TodoService::Create.new(create_params.merge(user_id: current_resource_owner.id), current_resource_owner).execute
    if @todo.persisted?
      render json: { status: 201, todo: @todo.as_json }, status: :created, location: api_todo_url(@todo)
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
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
    @folder = Folder.find_by(id: params[:folder_id], user_id: current_resource_owner.id)
    unless @folder
      render json: { error: 'Folder not found or not owned by user' }, status: :not_found
    end
  end

  def create_params
    # Merged the new and existing create_params
    params.require(:todo).permit(:title, :description, :due_date, :category, :priority, :recurring, :attachment, :status, :folder_id)
  end
end

# Validator class to handle the validation logic
class TodoValidator
  include ActiveModel::Validations

  validates :title, presence: { message: 'The title is required.' }, length: { maximum: 200, too_long: 'The title cannot exceed 200 characters.' }
  validates :description, length: { maximum: 1000, too_long: 'The description cannot exceed 1000 characters.' }
  validates :due_date, presence: true, date: { message: 'Invalid due date format.' }
  validates :priority, numericality: { only_integer: true, message: 'Invalid priority format.' }
  validates :status, numericality: { only_integer: true, message: 'Invalid status format.' }
  validate :folder_exists
  validate :user_exists

  attr_accessor :title, :description, :due_date, :priority, :status, :folder_id, :user_id

  def initialize(params = {})
    @title = params[:title]
    @description = params[:description]
    @due_date = params[:due_date]
    @priority = params[:priority]
    @status = params[:status]
    @folder_id = params[:folder_id]
    @user_id = params[:user_id]
  end

  def folder_exists
    errors.add(:folder_id, 'Folder not found.') unless Folder.exists?(id: folder_id)
  end

  def user_exists
    errors.add(:user_id, 'User not found.') unless User.exists?(id: user_id)
  end
end
