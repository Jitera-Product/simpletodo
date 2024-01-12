# rubocop:disable Style/ClassAndModuleChildren
class TodoFolderService::Create
  def initialize(user_id, name)
    @user_id = user_id
    @name = name
  end

  def execute
    user = User.find_by(id: @user_id)
    return { status: false, error: 'Invalid user' } unless user

    if user.todo_folders.exists?(name: @name)
      return { status: false, error: 'Folder name already exists' }
    end

    todo_folder = user.todo_folders.build(name: @name)
    return { status: true, folder: todo_folder } if todo_folder.save

    { status: false, error: todo_folder.errors.full_messages }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
