# typed: ignore
module Api
  class FoldersController < BaseController
    before_action :authenticate_user!
    before_action :set_folder, only: [:deletion_exceptions]
    before_action :authorize_folder, only: [:deletion_exceptions]

    # GET /api/folders/:id/deletion_exceptions
    def deletion_exceptions
      # Business logic to check for deletion exceptions
      if @folder.todos.any? { |todo| todo.deletion_exception? }
        render json: { status: 500, message: "An error occurred during the deletion process. Please try again later." }, status: :internal_server_error
      else
        render json: { status: 200, message: "No exceptions occurred during the deletion process." }, status: :ok
      end
    end

    private

    def set_folder
      @folder = Folder.find_by(id: params[:id])
      unless @folder
        render json: { message: "Folder not found." }, status: :not_found
      end
    end

    def authorize_folder
      authorize @folder, :deletion_exceptions?
    end

    def folder_params
      params.permit(:id)
    end
  end
end
