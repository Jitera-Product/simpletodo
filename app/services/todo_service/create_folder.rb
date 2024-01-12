# rubocop:disable Style/ClassAndModuleChildren
module TodoService
  class CreateFolder
    def initialize(user_id, name)
      @user_id = user_id
      @name = name
    end

    def execute
      User.find(@user_id).todo_folders.create!(name: @name)
    rescue ActiveRecord::RecordInvalid => e
      { error: e.message }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
