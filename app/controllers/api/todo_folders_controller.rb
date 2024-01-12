# typed: ignore
module Api
  class TodoFoldersController < Api::BaseController
    before_action :doorkeeper_authorize!

    def create
      authorize TodoFolder
      service = TodoFolderService::Create.new(create_params)
      result = service.execute

      if result.success?
        render json: result.as_json(only: [:folder_id, :name, :created_at, :updated_at]), status: :created
      else
        render json: { error: service.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def create_params
      params.require(:todo_folder).permit(:user_id, :name)
    end
  end
end
