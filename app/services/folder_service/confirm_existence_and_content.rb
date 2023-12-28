module FolderService
  class FolderEmptyError < StandardError; end

  def self.confirm_existence_and_content(folder_id)
    folder = Folder.find_by(id: folder_id)
    raise ActiveRecord::RecordNotFound, "Folder with id #{folder_id} not found" unless folder

    unless folder.todos.exists?
      raise FolderEmptyError, "Folder with id #{folder_id} is empty"
    end

    true
  rescue ActiveRecord::RecordNotFound => e
    # Handle folder not found exception
    raise e
  rescue FolderEmptyError => e
    # Handle folder empty exception
    raise e
  end
end
