# typed: ignore
module Api
  class TodoFoldersController < Api::BaseController
    before_action :doorkeeper_authorize!

    def create
      # Attempt to use the new code's approach first
      user_id = params[:user_id] || create_params[:user_id]
      folder_name = params[:name] || create_params[:name]
      uniqueness_check = TodoService::CheckFolderNameUniqueness.new(user_id, folder_name).execute

      if uniqueness_check[:error]
        render json: { error: uniqueness_check[:error] }, status: :unprocessable_entity
      else
        # Use the existing code's service pattern
        authorize TodoFolder
        service = TodoFolderService::Create.new(user_id: user_id, name: folder_name)
        result = service.execute

        if result.success?
          # Combine the new code's way of rendering the folder with the existing code's result structure
          render json: result.as_json(only: [:folder_id, :name, :created_at, :updated_at]), status: :created
        else
          # Use the existing code's error handling
          render json: { error: service.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue StandardError => e
      render json: error_response(nil, e), status: :internal_server_error
    end

    private

    def create_params
      params.require(:todo_folder).permit(:user_id, :name)
    end
  end
end
