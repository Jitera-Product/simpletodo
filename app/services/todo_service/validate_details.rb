
# rubocop:disable Style/ClassAndModuleChildren
class TodoService::ValidateDetails
  attr_accessor :details
  include ActiveModel::Validations

  def initialize(details)
    @details = details
  end

  def validate_todo_creation_params(params)
    errors = {}
    errors[:title] = I18n.t('activerecord.errors.messages.blank') if params[:title].blank?
    errors[:title] = I18n.t('activerecord.errors.messages.too_short', count: 10) if params[:title].length < 10
    return true if errors.empty?

    errors
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
