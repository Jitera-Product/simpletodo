
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

  def validate_folder_name(name)
    validation_errors = []
    is_valid = true

    unless name.present? && name.length.between?(3, 50)
      validation_errors << 'Folder name must be between 3 and 50 characters.'
      is_valid = false
    end

    unless name.match?(/\A[a-zA-Z0-9\s]+\z/)
      validation_errors << 'Folder name can only contain alphanumeric characters and spaces.'
      is_valid = false
    end

    { validation_errors: validation_errors, is_valid: is_valid }
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
