class Api::TodoFoldersController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create
    user_id = params[:user_id]
    name = params[:name]

    # Validate the user session
    validation_result = UserSessionService::Validate.new(user_id).execute
    return render json: { error: validation_result[:error] }, status: :unauthorized unless validation_result[:status]

    # Validate user existence
    user = User.find_by(id: user_id)
    unless user
      return render json: { error: 'User not found' }, status: :not_found
    end

    # Check the uniqueness of the folder name using the new service
    check_uniqueness = TodoService::CheckFolderNameUniqueness.new(user_id, name).execute
    if check_uniqueness[:error]
      return render json: { error: check_uniqueness[:error], suggested_action: check_uniqueness[:suggested_action] }, status: :unprocessable_entity
    end

    # Validate folder name presence
    if name.blank?
      return render json: { error: 'Folder name is required.' }, status: :bad_request
    end

    # Validate folder name length
    if name.length > 255
      return render json: { error: 'Folder name cannot exceed 255 characters.' }, status: :bad_request
    end

    # Check the authorization of the user to create folders
    unless TodoFolderPolicy.new(user).create?
      return render json: { error: 'User not authorized to create folders' }, status: :forbidden
    end

    # Create the folder if the name is unique and user is authorized
    todo_folder = user.todo_folders.new(name: name)
    if todo_folder.save
      render json: { status: 201, todo_folder: todo_folder }, status: :created
    else
      render json: { errors: todo_folder.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    folder_id = params[:id]
    return render json: { error: 'Folder not found or access denied.' }, status: :not_found unless folder_id.present?

    folder = TodoFolder.find_by(id: folder_id, user_id: current_user.id)
    if folder
      folder.destroy
      render json: { status: 200, message: 'To-Do folder creation has been successfully aborted.' }, status: :ok
    else
      render json: { error: 'Folder not found or access denied.' }, status: :forbidden
    end
  end

  private

  # Any private methods from the existing or new code would go here
end
