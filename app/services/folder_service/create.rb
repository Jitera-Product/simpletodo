# rubocop:disable Style/ClassAndModuleChildren
module FolderService
  class Create
    include ActiveModel::Validations

    validates :name, presence: { message: "The folder name is required." }
    validate :unique_name_for_user, :valid_color_format, :valid_icon_format

    def initialize(user_id, name, color, icon)
      @user_id = user_id
      @name = name
      @color = color
      @icon = icon
    end

    def call
      return { error: errors.full_messages, status: :unprocessable_entity } unless valid?

      begin
        folder = Folder.create!(
          user_id: @user_id,
          name: @name,
          color: @color,
          icon: @icon
        )
        { folder: folder, status: :created }
      rescue ActiveRecord::RecordInvalid => e
        { error: e.message, status: :unprocessable_entity }
      end
    end

    private

    def unique_name_for_user
      errors.add(:name, "A folder with this name already exists.") unless Folder.name_unique_for_user?(@name, @user_id)
    end

    def valid_color_format
      errors.add(:color, "Invalid color format.") unless @color.blank? || @color.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/)
    end

    def valid_icon_format
      # Assuming there's a method to validate icon format, otherwise use a regex or other validation logic
      errors.add(:icon, "Invalid icon format.") unless @icon.blank? || valid_icon?(@icon)
    end

    def valid_icon?(icon)
      # Placeholder for icon format validation logic
      true
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
