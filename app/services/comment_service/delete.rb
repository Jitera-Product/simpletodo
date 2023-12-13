# PATH: /app/services/comment_service/delete.rb
module CommentService
  class DeleteComment
    attr_reader :comment_id, :user

    def initialize(comment_id, user)
      @comment_id = comment_id
      @user = user
    end

    def execute
      comment = Comment.find_by(id: comment_id)
      return { status: 404, message: 'Comment not found' } unless comment

      user = User.find_by(id: user.id)
      return { status: 404, message: 'User not found' } unless user
      return { status: 401, message: 'User not authenticated' } unless user.authenticated?

      if comment.user_id == user.id
        comment.destroy
        { status: 200, message: 'Comment deleted successfully' }
      else
        { status: 403, message: 'Not authorized to delete this comment' }
      end
    end
  end
end
