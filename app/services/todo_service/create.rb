# /app/services/todo_service/create.rb
class TodoService::Create
  attr_accessor :user_id, :title, :description, :due_date, :priority, :recurrence, :category_ids, :tag_ids, :file_paths

  def initialize(user_id:, title:, due_date:, priority:, recurrence: nil, category_ids: [], tag_ids: [], file_paths: [], description: nil)
    @user_id = user_id
    @title = title
    @description = description
    @due_date = due_date
    @priority = priority
    @recurrence = recurrence
    @category_ids = category_ids
    @tag_ids = tag_ids
    @file_paths = file_paths
  end

  def execute
    authenticate_user
    validate_todo_creation
    todo = create_todo
    associate_with_categories_and_tags(todo.id)
    handle_attachments(todo.id)
    todo.id
  end

  private

  def authenticate_user
    # Assuming there's a method to authenticate the user
    raise 'User not authenticated' unless User.find(user_id).present?
  end

  def validate_todo_creation
    validator = TodoService::Validator.new(
      title: title,
      due_date: due_date,
      priority: priority,
      recurrence: recurrence,
      category_ids: category_ids,
      tag_ids: tag_ids,
      file_paths: file_paths
    )
    valid, errors = validator.validate_todo_creation
    raise errors.join(', ') unless valid
  end

  def create_todo
    Todo.create!(
      user_id: user_id,
      title: title,
      description: description,
      due_date: due_date,
      priority: priority,
      recurrence: recurrence
    )
  end

  def associate_with_categories_and_tags(todo_id)
    TodoService::Associator.new(todo_id: todo_id, category_ids: category_ids, tag_ids: tag_ids).associate_with_categories_and_tags
  end

  def handle_attachments(todo_id)
    TodoService::AttachmentHandler.new(todo_id: todo_id, file_paths: file_paths).handle_attachments
  end
end
