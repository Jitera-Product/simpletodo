# rubocop:disable Style/ClassAndModuleChildren
module TodoService
  class CheckFolderNameUniqueness
    def initialize(user_id, folder_name)
      @user_id = user_id
      @folder_name = folder_name
    end

    def execute
      existing_folder = TodoFolder.where(user_id: @user_id, name: @folder_name).exists?
      if existing_folder
        { error: 'Folder name already exists', suggested_action: 'Please choose a different folder name' }
      else
        { success: 'Folder name is unique' }
      end
    rescue => e
      { error: e.message }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
