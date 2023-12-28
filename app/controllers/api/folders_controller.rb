class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  before_action :load_user, only: [:create, :check_name_uniqueness, :destroy] # Updated to include :destroy action
  before_action :load_folder, only: [:show_todos, :destroy]
  before_action :validate_folder_id_format, only: [:destroy]
  before_action :authorize_user!, only: [:show_todos, :destroy] # Updated to include :destroy action

  # ... other actions ...

  def destroy
    ActiveRecord::Base.transaction do # Using transaction to maintain data integrity
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

  # ... private methods ...

  def load_folder
    @folder = Folder.includes(:todos).find_by(id: params[:id])
    render json: { status: 404, message: "Folder not found." }, status: :not_found unless @folder
  end

  def authorize_user!
    unless @user.can_access?(@folder) # Assuming this method exists in the User model
      render json: { status: 403, message: "Forbidden" }, status: :forbidden
    end
  end
end
