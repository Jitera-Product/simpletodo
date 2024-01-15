# typed: true
# frozen_string_literal: true

module Api
  class FoldersController < BaseController
    before_action :authenticate_user!, only: [:create]

    def create
      validation_result = UserSessionService::Validate.new(request.headers['Authorization']).execute
      if validation_result[:status]
        user_id = validation_result[:user].id
        user = validation_result[:user]

        if FolderPolicy.new(user).create?
          if params[:name].blank?
            render json: { error: 'The folder name is required.' }, status: :bad_request
            return
          end

          unless Folder.name_unique_for_user?(params[:name], user_id)
            render json: { error: 'A folder with this name already exists.' }, status: :unprocessable_entity
            return
          end

          unless params[:color].blank? || valid_color_format?(params[:color])
            render json: { error: 'Invalid color format.' }, status: :bad_request
            return
          end

          unless params[:icon].blank? || valid_icon_format?(params[:icon])
            render json: { error: 'Invalid icon format.' }, status: :bad_request
            return
          end

          folder_service = FolderService::Create.new(user_id, params[:name], params[:color], params[:icon])
          folder = folder_service.call
          if folder.persisted?
            render json: { folder_id: folder.id, name: folder.name, color: folder.color, icon: folder.icon, created_at: folder.created_at, updated_at: folder.updated_at }, status: :created
          else
            render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: 'You are not authorized to create folders.' }, status: :forbidden
        end
      else
        render json: { error: validation_result[:error] }, status: :unauthorized
      end
    end

    def check_name_uniqueness
      user_id = params[:user_id]
      name = params[:name]
      is_unique = !Folder.exists?(user_id: user_id, name: name)
      render json: { is_unique: is_unique }
    end

    def cancel_creation
      render json: { status: 'cancelled', message: 'Folder creation has been cancelled.' }, status: :ok
    end

    def validation_errors
      validation_result = UserSessionService::Validate.new(request.headers['Authorization']).execute
      if validation_result[:status]
        user = validation_result[:user]
        unless FolderPolicy.new(user).create?
          return render json: { error: 'Forbidden' }, status: :forbidden
        end
        error_message = params[:error_message]
        if error_message.blank?
          render json: { error: 'Error message is required.' }, status: :bad_request
        else
          render json: { status: 200, message: 'The folder name is already in use. Please choose a different name.' }, status: :ok
        end
      else
        render json: { error: validation_result[:error] }, status: :unauthorized
      end
    end

    def cancel
      validation_result = UserSessionService::Validate.new(request.headers['Authorization']).execute
      if validation_result[:status]
        user = validation_result[:user]
        if FolderPolicy.new(user).create?
          render json: { status: 200, message: 'Folder creation process has been canceled.' }, status: :ok
        else
          render json: { error: 'User does not have permission to cancel folder creation.' }, status: :forbidden
        end
      else
        render json: { error: 'User is not authenticated.' }, status: :unauthorized
      end
    end

    private

    def valid_color_format?(color)
      color.match?(/\A#(?:[0-9a-fA-F]{3}){1,2}\z/)
    end

    def valid_icon_format?(icon)
      # Assuming there's a method to validate icon format. This is a placeholder.
      # The actual implementation should validate the icon format according to the application's requirements.
      true
    end
  end
end
