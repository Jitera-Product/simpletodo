# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Index
  attr_accessor :params, :records, :query

  def initialize(params, _current_user = nil)
    @params = params

    @records = Todo
  end

  def execute
    user_id_equal
    order
    paginate
  end

  def user_id_equal
    return if params.dig(:bid_items, :user_id).blank?

    @records = if records.is_a?(Class)
                Todo.where(value.query)
               else
                 records.or(Todo.where('user_id = ?', params.dig(:bid_items, :user_id)))
               end
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