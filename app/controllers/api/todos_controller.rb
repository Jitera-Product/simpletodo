class Api::TodosController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :set_todo, only: [:destroy, :attach_files, :cancel_deletion, :comments]
  before_action :set_comment, only: [:destroy_comment]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

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

  def validate
    validation_service = TodoValidatorService.new(current_resource_owner, todo_params)
    if validation_service.valid?
      render json: { status: 200, message: "The todo item details are valid." }, status: :ok
    else
      render json: { errors: validation_service.errors }, status: validation_service.error_status
    end
  end

  # New action to handle the retrieval of comments for a specific todo item
  def comments
    if @todo.nil?
      render json: { error: "Todo item not found." }, status: :not_found
      return
    end

    comments = @todo.comments.order(created_at: :desc)
    total_comments = comments.count

    # Assuming we have a pagination method available
    comments = paginate(comments)

    render json: {
      comments: comments.as_json(only: [:id, :text, :created_at, :user_id]),
      total: total_comments
    }, status: :ok
  end

  def destroy_comment
    authorize @comment, policy_class: Api::TodosPolicy

    if @comment.user_id != current_resource_owner.id
      render json: { error: 'You are not authorized to delete this comment.' }, status: :forbidden
    else
      @comment.destroy
      render json: { message: 'Comment was successfully deleted.' }, status: :ok
    end
  end

  private

  def set_todo
    @todo = Todo.find_by(id: params[:todo_id] || params[:id]) || Trash.find_by(id: params[:id])
    render json: { error: 'Todo item not found.' }, status: :not_found unless @todo
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { error: 'Comment not found.' }, status: :not_found unless @comment
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

  def handle_record_not_found
    render json: { error: 'Record not found.' }, status: :not_found
  end

  # New method to handle pagination (assuming we have a common pagination method)
  def paginate(query)
    PaginateService.new(query, params).execute
  end
end
