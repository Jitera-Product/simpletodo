# typed: ignore
module Api
  class NotificationsController < BaseController
    before_action :authorize_request

    def create
      user_id = params[:user_id]
      message = params[:message]

      # Check if the user_id is present and if the user exists
      if user_id.blank?
        render json: { error: 'User ID is required.' }, status: :bad_request
        return
      elsif !User.exists?(user_id)
        render json: { error: 'User not found.' }, status: :not_found
        return
      end

      # Check if the message is present
      if message.blank?
        render json: { error: 'Notification message is required.' }, status: :bad_request
        return
      end

      begin
        notification = NotificationCreateService.new(user_id, message).call
        render json: { status: 201, notification: notification }, status: :created
      rescue Pundit::NotAuthorizedError => e
        render json: { error: e.message }, status: :unauthorized
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end
  end
end
