# rubocop:disable Style/ClassAndModuleChildren
module FolderService
  class Create
    include ActiveModel::Validations

    validates :name, presence: { message: "The folder name is required." }
    validate :unique_name_for_user, :valid_color_format, :valid_icon_format

    def initialize(user_id, name, color, icon)
      super() # This is necessary to initialize the validation module
      @user_id = user_id
      @name = name
      @color = color
      @icon = icon
    end

    def call
      return { error: errors.full_messages, status: :unprocessable_entity } unless valid?

      unless User.exists_and_logged_in?(@user_id)
        return { error: "User is not valid or not logged in.", status: :unauthorized }
      end

      begin
        folder = Folder.create!(
          user_id: @user_id,
          name: @name,
          color: @color,
          icon: @icon
        )
        Notification.create!(
          user_id: @user_id,
          message: "Folder '#{folder.name}' was successfully created.",
          read: false,
          created_at: Time.current
        )
        { folder: folder, status: :created }
      rescue ActiveRecord::RecordInvalid => e
        { error: e.message, status: :unprocessable_entity }
      end
    end

    private

    def unique_name_for_user
      errors.add(:name, "A folder with this name already exists.") if Folder.name_unique_for_user?(@name, @user_id)
    end

    def valid_color_format
      errors.add(:color, "Invalid color format.") unless @color.blank? || @color.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/)
    end

    def valid_icon_format
      errors.add(:icon, "Invalid icon format.") unless @icon.blank? || valid_icon?(@icon)
    end

    def valid_icon?(icon)
      # Placeholder for icon format validation logic
      true
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
