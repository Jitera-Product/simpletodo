class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  before_action :load_user, only: [:create, :check_name_uniqueness, :destroy] # Included :destroy action
  before_action :load_folder, only: [:show_todos, :destroy]
  before_action :validate_folder_id_format, only: [:destroy]
  before_action :authorize_user!, only: [:show_todos, :destroy] # Included :destroy action

  def create
    folder_params = params.require(:folder).permit(:name, :user_id)
    begin
      raise ArgumentError, "The folder name is required." if folder_params[:name].blank?
      
      # Use User.unique_folder_name? instead of folder_exists?
      unless User.unique_folder_name?(folder_params[:name], folder_params[:user_id])
        render json: { status: 409, message: "Folder name already exists. Please choose a different name." }, status: :conflict
      else
        folder = @user.folders.build(folder_params)
        folder.save!
        render json: { id: folder.id, name: folder.name, created_at: folder.created_at, updated_at: folder.updated_at }, status: :created
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "User not found." }, status: :not_found
    rescue ArgumentError => e
      render json: { status: 400, message: e.message }, status: :bad_request
    rescue ActiveRecord::RecordInvalid => e
      render json: { status: 422, message: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      begin
        if @folder.nil?
          render json: { status: 404, message: "Folder not found." }, status: :not_found
        else
          @folder.destroy!
          render json: { status: 200, message: "Folder and its todos have been successfully deleted." }, status: :ok
        end
      rescue ActiveRecord::RecordNotFound
        render json: { status: 404, message: "Folder not found." }, status: :not_found
      rescue ActiveRecord::RecordNotDestroyed => e
        render json: { status: 422, message: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { status: 500, message: e.message }, status: :internal_server_error
      end
    end
  end

  # ... rest of the code remains unchanged ...

  private

  def load_folder
    @folder = Folder.includes(:todos).find_by(id: params[:id])
    render json: { status: 404, message: "Folder not found." }, status: :not_found unless @folder
  end

  def authorize_user!
    unless @user.can_access?(@folder) # Assuming this method exists in the User model
      render json: { status: 403, message: "Forbidden" }, status: :forbidden
    end
  end

  # ... rest of the private methods remains unchanged ...
end
