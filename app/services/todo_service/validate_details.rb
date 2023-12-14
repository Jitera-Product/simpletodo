# PATH: /app/services/todo_service/validate_details.rb
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::ValidateDetails
  attr_accessor :details
  def initialize(details)
    @details = details
  end
  def execute
    uniqueness_result = validate_title_uniqueness(details[:user_id], details[:title])
    return send_response('Title is already in use', false) unless uniqueness_result[:is_unique]
    return send_response('Invalid due date', false) unless due_date_valid
    send_response('Details are valid', true)
  end
  def validate_title_uniqueness(user_id, title)
    is_unique = !Todo.exists?(user_id: user_id, title: title)
    { is_unique: is_unique }
  end
  private
  def due_date_valid
    details[:due_date].is_a?(Date) && details[:due_date].future?
  end
  def send_response(message, is_unique)
    { message: message, is_unique: is_unique }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
