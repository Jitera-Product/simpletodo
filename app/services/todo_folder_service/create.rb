# typed: true
module TodoFolderService
  class Create < BaseService
    attr_accessor :user_id, :name

    def initialize(user_id, name)
      @user_id = user_id
      @name = name
    end

    def execute
      ActiveRecord::Base.transaction do
        user = User.find_by(id: user_id)
        raise StandardError, 'User not found' unless user

        folder = user.todo_folders.build(name: name)
        if folder.save
          { success: true, folder: folder }
        else
          { success: false, errors: folder.errors.full_messages }
        end
      end
    rescue => e
      { success: false, errors: [e.message] }
    end
  end
end
