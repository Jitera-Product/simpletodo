class Api::FoldersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:destroy]

  # DELETE /api/folders/:id
  def destroy
    folder = set_folder
    if folder
      FolderService::DeleteTodos.new(folder.id).execute
      folder.destroy!
      render json: { message: 'Folder and all associated todos have been successfully deleted.' }, status: :ok
    else
      render json: { error: 'Folder not found or not owned by the user.' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: 'Failed to delete folder.' }, status: :unprocessable_entity
  end

  private

  def set_folder
    current_user.folders.find_by(id: params[:id])
  end
end
