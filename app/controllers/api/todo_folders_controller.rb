# typed: ignore
module Api
  class TodoFoldersController < Api::BaseController
    before_action :doorkeeper_authorize!, only: [:create, :abort]

    def create
      user_id = params[:user_id] || create_params[:user_id]
      folder_name = params[:name] || create_params[:name]
      uniqueness_check = TodoService::CheckFolderNameUniqueness.new(user_id, folder_name).execute

      if uniqueness_check[:error]
        render json: { error: uniqueness_check[:error] }, status: :unprocessable_entity
      else
        authorize TodoFolder
        service = TodoFolderService::Create.new(user_id: user_id, name: folder_name)
        result = service.execute

        if result.success?
          render json: result.as_json(only: [:folder_id, :name, :created_at, :updated_at]), status: :created
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
