class Api::FoldersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:create, :destroy] # Updated to include :destroy action

  def create
    folder_name = folder_params[:name]
    user_id = current_resource_owner.id

    if folder_name.blank? || folder_name.length > 255
      render json: { error: 'Invalid folder name' }, status: :unprocessable_entity
      return
    end

    if Folder.exists?(name: folder_name, user_id: user_id)
      render json: { error: 'Folder with this name already exists' }, status: :unprocessable_entity
      return
    end

    folder = Folder.new(name: folder_name, user_id: user_id)

    if folder.save
      render json: { folder_id: folder.id }, status: :created
    else
      render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    folder_id = params[:id]
    user_id = current_resource_owner.id

    begin
      # Ensure the ID is an integer
      Integer(folder_id)
    rescue ArgumentError
      render json: { error: 'Invalid ID format.' }, status: :bad_request
      return
    end

    folder = Folder.find_by(id: folder_id, user_id: user_id)
    if folder.nil?
      render json: { error: 'Folder not found.' }, status: :not_found
      return
    end

    if folder.destroy
      render json: { status: 200, message: 'Folder and its todo items successfully deleted.' }, status: :ok
    else
      render json: { error: folder.errors.full_messages }, status: :internal_server_error
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end
end
