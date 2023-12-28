class Api::FoldersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:create, :create_custom]

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

  # POST /api/folders
  def create_custom
    user_id = folder_params[:user_id]
    folder_name = folder_params[:name]

    return render json: { error: 'The folder name is required.' }, status: :bad_request if folder_name.blank?
    return render json: { error: 'The folder name cannot exceed 100 characters.' }, status: :bad_request if folder_name.length > 100
    return render json: { error: 'User not found.' }, status: :bad_request unless User.exists?(user_id)

    folder = Folder.new(name: folder_name, user_id: user_id)

    if folder.save
      render json: { status: 201, folder: folder.as_json(only: [:id, :name, :created_at, :user_id]) }, status: :created
    else
      render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: 'An unexpected error occurred on the server.' }, status: :internal_server_error
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :user_id)
  end
end
