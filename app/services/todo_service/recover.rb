# rubocop:disable Style/ClassAndModuleChildren
class TodoService::Recover
  attr_accessor :id, :user_id
  def initialize(id, user_id)
    @id = id
    @user_id = user_id
  end
  def execute
    todo = Todo.find_by(id: id, user_id: user_id, is_deleted: true)
    raise 'Todo item not found or you do not have permission to recover it or it is not deleted.' if todo.nil?
    todo.update(is_deleted: false)
    { message: 'Todo item has been recovered.', id: todo.id }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
