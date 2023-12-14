# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create
  include ActiveModel::Validations
  ALLOWED_PRIORITIES = %w[low medium high].freeze
  ALLOWED_RECURRING_TYPES = %w[daily weekly monthly].freeze
  attr_accessor :params, :todo, :current_user
  validate :due_date_in_future, :valid_recurring_type, :valid_priority, :title_present
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end
  def self.call(params, current_user)
    new(params, current_user).execute
  end
  def execute
    validate_input
    authenticate_user
    validate_uniqueness_of_title
    run_validations
    create_todo
    associate_with_categories(params[:category_ids], @todo.id) if params[:category_ids].present?
    handle_attachments
    { todo_id: @todo.id }
  end
  private
  def validate_input
    # Adjusted to use the new class name for input validation
    TodoService::ValidateInput.new(params).execute
  end
  def authenticate_user
    # Combined the authentication logic from the new code with the existing code
    raise 'User must be authenticated' unless current_user && current_user.id == params[:user_id]
    UserSessionService::Validate.call(user_id: current_user.id)
  end
  def validate_uniqueness_of_title
    if current_user.todos.exists?(title: params[:title])
      errors.add(:title, 'has already been taken')
    end
  end
  def run_validations
    raise ActiveRecord::RecordInvalid.new(self) unless valid?
  end
  def title_present
    errors.add(:title, 'cannot be blank') if params[:title].blank?
  end
  def due_date_in_future
    errors.add(:due_date, 'must be in the future') if params[:due_date].present? && params[:due_date] <= Time.current
  end
  def valid_recurring_type
    if params[:is_recurring] && !ALLOWED_RECURRING_TYPES.include?(params[:recurring_type])
      errors.add(:recurring_type, 'is not a valid option')
    end
  end
  def valid_priority
    errors.add(:priority, 'is not included in the list') unless ALLOWED_PRIORITIES.include?(params[:priority])
  end
  def create_todo
    # Merged the create_todo logic to include the description defaulting from the existing code
    @todo = current_user.todos.new(params.except(:categories, :attachments, :user_id, :category_ids).merge(description: params.fetch(:description, '')))
    raise ActiveRecord::RecordNotSaved.new(@todo) unless @todo.save
  end
  def associate_with_categories(category_ids, todo_id)
    # Replaced the existing association logic with the new one, as it includes transaction handling
    associations_created = false
    ActiveRecord::Base.transaction do
      category_ids.each do |category_id|
        category = Category.find_by(id: category_id)
        raise "Category with id #{category_id} does not exist" unless category
        TodoCategory.create!(category_id: category_id, todo_id: todo_id)
      end
      associations_created = true
    end
    associations_created
  rescue ActiveRecord::RecordInvalid => e
    raise "Failed to create associations: #{e.message}"
  end
  def handle_attachments
    # Kept the new code's logic for handling attachments as it's more concise and direct
    if params[:attachments].present?
      params[:attachments].each do |attachment|
        @todo.attachments.create(file: attachment)
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
