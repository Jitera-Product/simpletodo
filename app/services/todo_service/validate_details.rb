# rubocop:disable Style/ClassAndModuleChildren
class TodoService::ValidateDetails
  attr_accessor :details
  def initialize(details)
    @details = details
  end
  def execute
    return send_response('Invalid details') unless title_unique && due_date_valid
    send_response('Details are valid')
  end
  private
  def title_unique
    Todo.where(user_id: details[:user_id], title: details[:title]).empty?
  end
  def due_date_valid
    return false unless details[:due_date].future?
    Todo.where(user_id: details[:user_id]).where('due_date = ?', details[:due_date]).empty?
  end
  def send_response(message)
    { message: message }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
