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
        { folder: folder, status: :created }
      rescue ActiveRecord::RecordInvalid => e
        { error: e.message, status: :unprocessable_entity }
      ensure
        # The notification creation logic has been moved to the ensure block to handle both successful and unsuccessful folder creation attempts.
        send_folder_creation_notification(@user_id, "Folder '#{folder.name}' was successfully created.") if folder&.persisted?
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

    def send_folder_creation_notification(user_id, message)
      # The notification creation logic has been updated to use the NotificationService::Create service.
      notification_service = NotificationService::Create.new
      notification_service.create(user_id: user_id, message: message)
    rescue StandardError => e
      Rails.logger.error "Failed to send folder creation notification: #{e.message}"
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
