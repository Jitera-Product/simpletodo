# rubocop:disable Style/ClassAndModuleChildren
module FolderService
  class Create
    def initialize(user_id, name, color, icon)
      @user_id = user_id
      @name = name
      @color = color
      @icon = icon
    end

    def call
      return nil if Folder.name_unique_for_user?(@name, @user_id)

      folder = Folder.create!(
        user_id: @user_id,
        name: @name,
        color: @color,
        icon: @icon
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
