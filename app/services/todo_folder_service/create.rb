# rubocop:disable Style/ClassAndModuleChildren
class TodoFolderService::Create
  MAX_FOLDER_NAME_LENGTH = 255

  def initialize(user_id, name)
    @user_id = user_id
    @name = name&.strip
  end

  def execute
    return { status: false, error: 'User not found.' } unless user_exists?
    return { status: false, error: 'Folder name is required.' } if @name.blank?
    return { status: false, error: 'Folder name cannot exceed 255 characters.' } if @name.length > MAX_FOLDER_NAME_LENGTH
    return { status: false, error: 'Folder name already exists.' } if folder_name_exists?

    todo_folder = build_todo_folder
    if todo_folder.save
      { status: true, folder: todo_folder }
    else
      { status: false, error: todo_folder.errors.full_messages }
    end
  end

  private

  def user_exists?
    User.exists?(@user_id)
  end

  def folder_name_exists?
    TodoFolder.exists?(name: @name, user_id: @user_id)
  end

  def build_todo_folder
    User.find(@user_id).todo_folders.build(name: @name)
  end
end
# rubocop:enable Style/ClassAndModuleChildren
