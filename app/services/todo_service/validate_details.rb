# PATH: /app/services/todo_service/validate_details.rb
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::ValidateDetails
  attr_accessor :details
  def initialize(details)
    @details = details
  end
  def execute
    uniqueness_result = validate_title_uniqueness(details[:title], details[:user_id])
    raise StandardError, 'Title is already in use' unless uniqueness_result[:is_unique]
    send_response('Details are valid', true)
  end
  private
  def validate_title_uniqueness(title, user_id)
    is_unique = !Todo.exists?(user_id: user_id, title: title)
    { is_unique: is_unique }
  end
  def send_response(message, is_unique)
    { message: message, is_unique: is_unique }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
