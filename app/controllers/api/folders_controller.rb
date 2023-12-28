# FILE PATH: /app/controllers/api/folders_controller.rb
class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  include FolderService

  def confirm_deletion
    folder_id = params[:folder_id]
    
    # Validate folder_id is an integer
    unless folder_id.to_i.to_s == folder_id.to_s
      render json: { error: "Invalid folder ID format." }, status: :bad_request
      return
    end

    begin
      folder = Folder.find(folder_id)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Folder not found." }, status: :not_found
      return
    end

    confirm_existence_and_content(folder_id)
    policy = ApplicationPolicy.new(current_user, folder)

    if policy.user_can_delete_folders?(current_user.id)
      render json: {
        status: 200,
        message: "Are you sure you want to delete this folder and all its contents?",
        folder: {
          id: folder.id,
          name: folder.name,
          created_at: folder.created_at
        }
      }, status: :ok
    else
      render json: { error: "Forbidden" }, status: :forbidden
    end
  rescue FolderService::FolderEmptyError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def authenticate_user!
    # Method to check if user is authenticated
  end
end
