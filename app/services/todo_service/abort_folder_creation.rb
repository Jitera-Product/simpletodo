# rubocop:disable Style/ClassAndModuleChildren
module TodoService
  class AbortFolderCreation
    attr_accessor :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def execute
      return { error: 'User does not exist' } unless User.exists?(user_id)

      Rails.logger.info("User #{user_id} has aborted the folder creation process.")
      { message: 'Folder creation process has been successfully aborted.' }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
