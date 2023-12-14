# PATH: /app/services/todo_service/create.rb
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
    associate_categories
    handle_attachments
    { todo_id: @todo.id }
  end
  private
  def validate_input
    TodoService::ValidateDetails.new(params).execute
  end
  def authenticate_user
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
    @todo = current_user.todos.new(params.except(:categories, :attachments, :user_id).merge(description: params.fetch(:description, '')))
    raise ActiveRecord::RecordNotSaved.new(@todo) unless @todo.save
  end
  def associate_categories
    if params[:category_ids].present?
      category_ids = params[:category_ids].select { |id| Category.exists?(id) }
      TodoCategoryAssociator.new(@todo, category_ids).associate!
    end
  end
  def handle_attachments
    if params[:attachments].present?
      TodoAttachmentsService.new(@todo, params[:attachments]).process!
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
