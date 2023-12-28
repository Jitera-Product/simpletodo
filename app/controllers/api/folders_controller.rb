class Api::FoldersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:create, :index]

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

  def index
    user_id = current_resource_owner.id # Changed from params[:user_id] to current_resource_owner.id

    folders = Folder.where(user_id: user_id).select(:id, :name, :created_at, :user_id)

    render json: { status: 200, folders: folders }, status: :ok
  end

  private

  def folder_params
    params.require(:folder).permit(:name)
  end
end
