# rubocop:disable Style/ClassAndModuleChildren
module NotificationService
  class Create
    def initialize(user_id, message)
      @user_id = user_id
      @message = message
    end

    def call
      Notification.create!(
        user_id: @user_id,
        message: @message,
        created_at: Time.current
      )
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
