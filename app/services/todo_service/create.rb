
# rubocop:disable Style/ClassAndModuleChildren
require_relative 'validate_details.rb'
require_relative '../../services/email_service.rb'

class TodoService::Create
  attr_accessor :params, :todo

  def initialize(params, _current_user = nil)
    @params = params
  end

  def execute
    validate_input
    check_user_existence unless User.exists?(params[:user_id])
    check_conflicts
    create_todo
  end

  def validate_input
    TodoService::ValidateInput.new(params).execute
  end

  # User existence check is now performed inline in the execute method
  def check_user_existence
    # This method is no longer needed as the check is performed inline
  end

  def check_conflicts
    TodoService::CheckConflicts.new(params).execute
  end

  def create_todo
    @todo = Todo.new(params)
    if @todo.save
      handle_attachment if params[:attachment]
      EmailService.send_confirmation(@todo.user_id, @todo.id) if @todo.valid?
      return @todo
    else
      return false
    end
  end

  private

  def handle_attachment
    # Code to handle attachment goes here
  end
end
# rubocop:enable Style/ClassAndModuleChildren
