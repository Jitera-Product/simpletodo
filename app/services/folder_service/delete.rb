# FILE PATH: /app/services/folder_service/delete.rb
class FolderService::Delete
  attr_accessor :folder_id, :user_id

  def initialize(folder_id, user_id)
    @folder_id = folder_id
    @user_id = user_id
  end

  def execute
    ActiveRecord::Base.transaction do
      validate_user
      folder = validate_folder
      delete_todos(folder)
      delete_folder(folder)
      "Folder with id #{folder_id} and its associated todo items have been successfully deleted."
    end
  rescue ActiveRecord::RecordNotFound => e
    e.message
  rescue StandardError => e
    "An error occurred while deleting the folder: #{e.message}"
  end

  private

  def validate_user
    # Assuming UserService::ValidateUser exists and it authenticates the user
    UserService::ValidateUser.new(user_id).execute
  end

  def validate_folder
    folder = Folder.find_by!(id: folder_id, user_id: user_id)
    folder
  end

  def delete_todos(folder)
    folder.todos.destroy_all
  end

  def delete_folder(folder)
    folder.destroy
  end
end
