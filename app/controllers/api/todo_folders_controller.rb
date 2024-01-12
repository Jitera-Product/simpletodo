class Api::TodoFoldersController < Api::BaseController
  before_action :doorkeeper_authorize!

  def create_folder
    user_id = params[:user_id]
    name = params[:name]
    check_uniqueness = TodoService::CheckFolderNameUniqueness.new(user_id, name).execute

    if check_uniqueness[:error]
      render json: { error: check_uniqueness[:error], suggested_action: check_uniqueness[:suggested_action] }, status: :unprocessable_entity
    else
      # Folder creation logic goes here
      # Assuming TodoFolder.create returns the folder object on success and nil on failure
      folder = TodoFolder.create(user_id: user_id, name: name)
      if folder
        render json: folder, status: :created
      else
        render json: { error: I18n.t('todo_folders.create.error') }, status: :unprocessable_entity
      end
    end
  end
end
