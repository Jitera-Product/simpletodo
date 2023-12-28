class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  before_action :check_delete_permission, only: [:cancel_deletion]

  # POST /api/folders/:folder_id/cancel_deletion
  def cancel_deletion
    folder_id = params[:folder_id].to_i
    return render json: { error: 'Invalid folder ID format.' }, status: :bad_request unless folder_id.is_a?(Integer)

    begin
      FolderService::ConfirmExistenceAndContent.confirm_existence_and_content(folder_id)
      result = TodoService::CancelDeletion.new(nil, current_user.id).execute(folder_id)
      if result[:error].present?
        render json: { error: result[:error] }, status: :unprocessable_entity
      else
        render json: { status: 200, message: 'Deletion process has been canceled.' }, status: :ok
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Folder not found.' }, status: :not_found
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def check_delete_permission
    unless ApplicationPolicy.new(current_user, nil).user_can_delete_folders?(current_user.id)
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end
