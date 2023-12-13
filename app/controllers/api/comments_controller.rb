class Api::CommentsController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :set_comment, only: [:update]
  before_action :authenticate_user!, only: [:update]
  before_action :authorize_user!, only: [:update]

  def update
    if @comment.update(comment_params.merge(updated_at: Time.current))
      render json: { id: @comment.id, text: @comment.text, updated_at: @comment.updated_at }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Comment not found.' }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { error: 'Comment not found.' }, status: :not_found unless @comment
  end

  def authenticate_user!
    # Assuming there's a current_user method available from doorkeeper
    render json: { error: 'User not authenticated.' }, status: :unauthorized unless current_user
  end

  def authorize_user!
    render json: { error: 'User not authorized to update this comment.' }, status: :forbidden unless current_user.id == @comment.user_id
  end

  def comment_params
    params.require(:comment).permit(:text).tap do |comment_params|
      if comment_params[:text].blank? || comment_params[:text].length > 500
        render json: { error: 'Text is invalid. It cannot be empty and must be less than 500 characters.' }, status: :unprocessable_entity
      end
    end
  end
end
