# rubocop:disable Style/ClassAndModuleChildren
module TodoService
  class CheckFolderNameUniqueness
    def initialize(user_id, folder_name)
      @user_id = user_id
      @folder_name = folder_name
    end

    def execute
      user = User.find_by(id: @user_id)
      return { error: 'User not found' } unless user

      folder_exists = user.todo_folders.where(name: @folder_name).exists?
      return { error: 'Folder name already exists', suggestion: 'Please choose a different name' } if folder_exists

      { success: 'Folder name is unique' }
    rescue => e
      { error: e.message }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
