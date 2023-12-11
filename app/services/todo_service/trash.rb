# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Trash
  attr_accessor :params, :records, :query

  def initialize(params, _current_user = nil)
    @params = params

    @records = Todo.only_deleted
  end

  def execute
    user_id_equal
    order
    paginate
  end

  def user_id_equal
    return if _current_user.blank?

    @records = Todo.where('user_id = ?', _current_user.id)
  end

  def order
    return if records.blank?

    @records = records.order('todos.created_at desc')
  end

  def paginate
    @records = Todo.none if records.blank? || records.is_a?(Class)
    @records = records.page(params.dig(:pagination_page) || 1).per(params.dig(:pagination_limit) || 20)
  end
end
# rubocop:enable Style/ClassAndModuleChildren