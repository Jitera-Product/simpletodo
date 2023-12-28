# FILE PATH: /app/controllers/api/folders_controller.rb
class Api::FoldersController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:index]

  def index
    # Ensure that we are getting the user_id from the authenticated user
    user_id = current_user.id
    # Retrieve folders for the authenticated user
    folders = Folder.where(user_id: user_id).select(:id, :name)
    render json: folders, status: :ok
  end
end
