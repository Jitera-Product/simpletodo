# FILE PATH: /app/services/todo_service/delete_folder.rb
module TodoService
  class DeleteFolder < BaseService
    attr_accessor :id, :user_id

    def initialize(id, user_id)
      @id = id
      @user_id = user_id
    end

    def execute
      ActiveRecord::Base.transaction do
        validate_folder
        delete_todos
        delete_folder
      end
      "Folder with id #{@id} and all associated todos have been successfully deleted."
    rescue StandardError => e
      "An error occurred while deleting the folder: #{e.message}"
    end

    private

    def validate_folder
      folder = Folder.find_by(id: id, user_id: user_id)
      raise StandardError, "Folder not found or doesn't belong to the user" unless folder
    end

    def delete_todos
      Todo.where(folder_id: id).destroy_all
    end

    def delete_folder
      folder = Folder.find(id)
      folder.destroy
      logger.info "Folder with id #{id} has been deleted."
    end
  end
end
