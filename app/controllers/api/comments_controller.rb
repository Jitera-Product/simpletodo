class Api::CommentsController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :authenticate_user!
  before_action :set_comment, only: [:update, :destroy] # Combined actions from new and existing code
  before_action :set_todo, only: [:create, :update, :destroy] # Combined actions from new and existing code
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

  def update
    if @comment.user_id != current_resource_owner.id || @comment.todo_id != @todo.id
      render json: { error: 'You are not authorized to edit this comment or comment does not belong to the todo.' }, status: :unauthorized
      return
    end

    if comment_params[:content].blank? || comment_params[:content].length > 500
      render json: { error: 'Content must be 500 characters or less.' }, status: :unprocessable_entity
      return
    end

    begin
      @comment.update!(content: comment_params[:content], updated_at: Time.current)
      render json: { status: 200, comment: @comment.as_json(only: [:id, :content, :updated_at, :todo_id, :user_id]) }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  def destroy
    # Ensure that the current user is the owner of the comment
    unless @comment.user_id == current_resource_owner.id
      render json: { error: 'You are not authorized to delete this comment.' }, status: :unauthorized
      return
    end

    if @comment.destroy
      render json: { status: 200, message: 'Comment successfully deleted.' }, status: :ok
    else
      render json: { error: 'An unexpected error occurred.' }, status: :internal_server_error
    end
  end

  private

  def authenticate_user!
    user = current_resource_owner || current_user
    render json: { error: 'User not authenticated.' }, status: :unauthorized unless user
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { error: 'Comment not found.' }, status: :not_found unless @comment
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
    params.require(:comment).permit(:content).merge(params.permit(:todo_id, :user_id))
  end
end
