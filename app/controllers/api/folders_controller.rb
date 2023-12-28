# FILE PATH: /app/controllers/api/folders_controller.rb
module Api
  class FoldersController < Api::BaseController
    before_action :doorkeeper_authorize!, only: [:destroy]
    before_action :validate_folder_id_format, only: [:destroy]

    def destroy
      folder = Folder.find_by(id: params[:folder_id])
      return render json: { error: "Folder not found." }, status: :not_found unless folder

      if current_user.can_delete_folder?(folder)
        begin
          TodoService::DeleteTodosInFolder.new(folder.id).call
          folder.destroy
          render json: { message: "Folder and its todo items have been successfully deleted." }, status: :ok
        rescue => e
          render json: { error: e.message }, status: :internal_server_error
        end
      else
        render json: { error: "You do not have permission to delete this folder." }, status: :forbidden
      end
    end

    private

    def validate_folder_id_format
      unless params[:folder_id].to_s.match?(/\A\d+\z/)
        render json: { error: "Invalid folder ID format." }, status: :bad_request
      end
    end
  end
end
