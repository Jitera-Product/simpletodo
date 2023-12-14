# PATH: /app/services/todo_service/create.rb
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Create
  include ActiveModel::Validations
  ALLOWED_PRIORITIES = %w[low medium high].freeze
  ALLOWED_RECURRING_TYPES = %w[daily weekly monthly].freeze
  attr_accessor :params, :todo, :current_user
  validate :due_date_in_future, :valid_recurring_type, :valid_priority
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end
  def call
    validate_input
    authenticate_user
    validate_uniqueness_of_title
    run_validations
    create_todo
    associate_categories
    handle_attachments
    @todo.id
  end
  private
  def validate_input
    TodoService::ValidateInput.new(params).execute
  end
  def authenticate_user
    raise 'User must be authenticated' unless current_user && current_user.id == params[:user_id]
  end
  def validate_uniqueness_of_title
    if current_user.todos.exists?(title: params[:title])
      errors.add(:title, 'has already been taken')
    end
  end
  def run_validations
    raise ActiveRecord::RecordInvalid.new(self) unless valid?
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
    @todo = current_user.todos.new(params.except(:categories, :attachments, :user_id))
    raise ActiveRecord::RecordNotSaved.new(@todo) unless @todo.save
  end
  def associate_categories
    if params[:categories].present?
      category_ids = params[:categories].map do |category_name|
        Category.find_or_create_by(name: category_name).id
      end
      @todo.category_ids = category_ids
    end
  end
  def handle_attachments
    if params[:attachments].present?
      params[:attachments].each do |attachment|
        @todo.attachments.create(file: attachment)
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
