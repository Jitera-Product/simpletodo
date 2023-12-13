class Api::CommentsController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :authenticate_user!
  before_action :set_todo, only: [:create]
  before_action :validate_user_and_todo, only: [:create]

  def create
    validator = CommentValidator.new(comment_params)
    unless validator.valid?
      render json: { error: validator.errors.full_messages.join(', ') }, status: :bad_request
      return
    end

    begin
      comment = Comment.create!(comment_params.merge(created_at: Time.current, updated_at: Time.current))
      render json: comment.as_json(only: [:id, :content, :created_at, :todo_id, :user_id]), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def authenticate_user!
    # Assuming there's a method to authenticate the user
    render json: { error: 'User not authenticated' }, status: :unauthorized unless current_user
  end

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id])
    render json: { error: 'Todo item not found.' }, status: :not_found unless @todo
  end

  def validate_user_and_todo
    user = User.find_by(id: params[:user_id])
    unless user && @todo && @todo.user_id == user.id
      render json: { error: 'Invalid user or todo.' }, status: :forbidden
    end
  end

  def comment_params
    params.permit(:content, :todo_id, :user_id)
  end
end
