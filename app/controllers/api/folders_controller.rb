module Api
  class FoldersController < BaseController
    def create
      validation_result = UserSessionService::Validate.new(request.headers['Authorization']).execute
      if validation_result[:status]
        user_id = validation_result[:user].id
        if Folder.name_unique_for_user?(params[:name], user_id)
          folder = FolderService::Create.new.call(user_id, params[:name], params[:color], params[:icon])
          render json: { folder_id: folder.id, name: folder.name, color: folder.color, icon: folder.icon, created_at: folder.created_at, updated_at: folder.updated_at }, status: :created
        else
          render json: { error: 'Folder name already exists' }, status: :unprocessable_entity
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
  end
end
