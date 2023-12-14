# PATH: /app/services/todo_service/validate_details.rb
# rubocop:disable Style/ClassAndModuleChildren
require 'date'
class TodoService::ValidateDetails
  attr_accessor :details
  def initialize(details)
    @details = details
  end
  def execute
    uniqueness_result = validate_title_uniqueness(details[:user_id], details[:title])
    return send_response('Title is already in use', false) unless uniqueness_result[:is_unique]
    due_date_result = validate_due_date(details[:due_date])
    return due_date_result unless due_date_result[:is_valid]
    send_response('Details are valid', true)
  end
  private
  def validate_title_uniqueness(user_id, title)
    is_unique = !Todo.exists?(user_id: user_id, title: title)
    { is_unique: is_unique }
  end
  def validate_due_date(due_date)
    begin
      parsed_due_date = DateTime.parse(due_date)
      if parsed_due_date > DateTime.now
        { is_valid: true }
      else
        send_response('Due date must be set in the future', false)
      end
    rescue ArgumentError
      send_response('Invalid due date format', false)
    end
  end
  def send_response(message, is_valid)
    { message: message, is_valid: is_valid }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
