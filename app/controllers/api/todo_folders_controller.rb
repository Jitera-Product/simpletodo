# typed: ignore
module Api
  class TodoFoldersController < Api::BaseController
    before_action :doorkeeper_authorize!, only: [:create, :abort]

    include ActiveModel::Validations::FolderNameValidator

    def create
      user_id = params[:user_id] || create_params[:user_id]
      folder_name = params[:name] || create_params[:name]

      # Validate user existence
      unless User.exists?(user_id)
        render json: { error: "User not found." }, status: :bad_request
        return
      end

      # Validate folder name
      if folder_name.blank?
        render json: { error: "Folder name is required." }, status: :bad_request
        return
      elsif folder_name.length > 255
        render json: { error: "Folder name cannot exceed 255 characters." }, status: :bad_request
        return
      end

      uniqueness_check = TodoService::CheckFolderNameUniqueness.new(user_id, folder_name).execute

      if uniqueness_check[:error]
        render json: { error: uniqueness_check[:error] }, status: :unprocessable_entity
      else
        authorize TodoFolder
        service = TodoFolderService::Create.new(user_id: user_id, name: folder_name)
        result = service.execute

        if result.success?
          folder = result[:todo_folder] || result
          render json: { status: 201, todo_folder: folder.as_json(only: [:id, :user_id, :name, :created_at, :updated_at]) }, status: :created
        else
          render json: { error: service.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue StandardError => e
      render json: error_response(nil, e), status: :internal_server_error
    end

    def abort
      authorize TodoFolder
      service = TodoService::AbortFolderCreation.new(current_user.id)
      result = service.execute

      if result[:error]
        render json: { error: result[:error] }, status: :forbidden
      else
        render json: { message: "To-Do folder creation process has been aborted." }, status: :ok
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: 'You are not authorized to perform this action.' }, status: :unauthorized
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def create_params
      params.require(:todo_folder).permit(:user_id, :name)
    end
  end
end
