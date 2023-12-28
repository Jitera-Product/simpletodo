class Api::FoldersController < Api::BaseController
  before_action :load_user, only: [:create]

  def create
    folder_params = params.require(:folder).permit(:name, :user_id)
    begin
      if folder_exists?(folder_params[:name], folder_params[:user_id])
        render json: { status: 409, message: "Folder with the given name already exists." }, status: :conflict
      else
        folder = Folder.new(folder_params)
        folder.save!
        render json: { id: folder.id, name: folder.name, created_at: folder.created_at, updated_at: folder.updated_at }, status: :created
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "User not found." }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 422, message: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  private

  def load_user
    @user = User.find(params[:folder][:user_id])
  end

  def folder_exists?(name, user_id)
    Folder.exists?(name: name, user_id: user_id)
  end
end
