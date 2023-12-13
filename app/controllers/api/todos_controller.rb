class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :set_todo, only: [:create_comment, :destroy, :attach_files, :cancel_deletion, :comments]

  def index
    todos = TodoService::Index.new(params.permit!, current_resource_owner).execute

    render json: todos, status: :ok
  end

  def trash
    todos = TodoService::Trash.new(params.permit!, current_resource_owner).execute

    render json: todos, status: :ok
  end

  def create
    validator = TodoService::Validator.new(todo_params)
    unless validator.valid?
      render json: { error: validator.errors.full_messages.join(', ') }, status: :bad_request
      return
    end

    begin
      todo_id = TodoService::execute(
        user_id: current_resource_owner.id,
        title: todo_params[:title],
        due_date: todo_params[:due_date],
        priority: todo_params[:priority],
        recurrence: todo_params[:recurrence],
        category_ids: todo_params[:category_id] ? [todo_params[:category_id]] : [],
        tag_ids: todo_params[:tag_ids] || [],
        file_paths: todo_params[:attachments] || [],
        description: todo_params[:description]
      )

      @todo = Todo.find(todo_id)
      render 'api/todos/show', status: :created
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  def create_comment
    return render json: { error: 'Todo not found.' }, status: :not_found unless @todo
    return render json: { error: 'You are not authorized to comment on this todo.' }, status: :unauthorized unless @todo.user_id == current_resource_owner.id

    comment = @todo.comments.build(comment_params)
    if comment.save
      render 'api/todos/create_comment', status: :created, locals: { comment: comment }
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def attach_files
    validate_attachments_params

    result = TodoService::AttachmentHandler.new(
      todo_id: @todo.id,
      file_paths: attachments_params[:attachments]
    ).execute

    if result[:status] == :created
      render json: result, status: :created
    else
      render json: { error: result[:error] }, status: result[:status]
    end
  end

  def destroy
    authorize @todo, policy_class: Api::TodosPolicy

    result = TodoService::DeleteTodoItem.new(@todo.id, current_resource_owner).execute
    if result[:status] == 200
      render json: result, status: :ok
    else
      render json: { error: result[:message] }, status: result[:status]
    end
  end

  def cancel_deletion
    if @todo.nil?
      render json: { error: "This to-do item is not found." }, status: :not_found
    elsif !validate_cancellation(@todo.id)
      render json: { error: "Cancellation is not valid or the time frame has expired." }, status: :unprocessable_entity
    else
      if Trash.restore(@todo.id)
        render json: { status: 200, message: "To-do item deletion has been successfully canceled." }, status: :ok
      else
        render json: { error: "Could not cancel the deletion of the to-do item." }, status: :internal_server_error
      end
    end
  end

  def comments
    begin
      comments = Comment.where(todo_id: @todo.id).order(created_at: :desc)
      serialized_comments = comments.map do |comment|
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          todo_id: comment.todo_id,
          user_id: comment.user_id
        }
      end
      render json: { comments: serialized_comments, total_count: comments.size }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id] || params[:id]) || Trash.find_by(id: params[:id])
    render json: { error: 'Todo item not found.' }, status: :not_found unless @todo
  end

  def validate_attachments_params
    validator = TodoService::Validator.new(attachments_params)
    unless validator.valid_attachments?
      render json: { error: 'Invalid attachment file path or file size limit exceeded.' }, status: :unprocessable_entity
    end
  end

  def attachments_params
    params.permit(attachments: [])
  end

  def todo_params
    params.permit(
      :title,
      :description,
      :due_date,
      :priority,
      :recurrence,
      :category_id,
      tag_ids: [],
      attachments: []
    )
  end

  def validate_cancellation(id)
    Trash.validate_cancellation(id)
  end

  def comment_params
    params.require(:comment).permit(:content).tap do |comment_params|
      if comment_params[:content].length > 500
        render json: { error: 'Content must be 500 characters or less.' }, status: :unprocessable_entity
        return
      end
    end
  end
end
