class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  before_action :load_user, only: [:create, :check_name_uniqueness]
  before_action :load_folder, only: [:destroy]
  before_action :validate_folder_id_format, only: [:destroy]

  def create
    folder_params = params.require(:folder).permit(:name, :user_id)
    begin
      raise ArgumentError, "The folder name is required." if folder_params[:name].blank?
      
      if folder_exists?(folder_params[:name], folder_params[:user_id])
        render json: { status: 409, message: "Folder name already exists. Please choose a different name." }, status: :conflict
      else
        folder = @user.folders.build(folder_params)
        folder.save!
        render json: { status: 201, folder: folder_response(folder) }, status: :created
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

  def check_name_uniqueness
    name = params[:name]
    user_id = params[:user_id]

    if name.blank?
      render json: { status: 400, message: "The folder name is required." }, status: :bad_request
      return
    end

    unless User.exists?(user_id)
      render json: { status: 404, message: "User not found." }, status: :not_found
      return
    end

    if folder_exists?(name, user_id)
      render json: { status: 200, is_unique: false, message: "Folder name already exists. Please choose a different name." }, status: :ok
    else
      render json: { status: 200, is_unique: true }, status: :ok
    end
  end

  def destroy
    begin
      delete_service = TodoService::DeleteFolder.new(@folder.id, @user.id)
      delete_service.execute
      render json: { status: 200, message: "Folder and its todos have been successfully deleted." }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "Folder not found." }, status: :not_found
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  private

  def authenticate_user!
    # Assuming there's a method to authenticate user
    # This is a placeholder for actual authentication logic
    raise "Unauthorized" unless user_signed_in?
  end

  def user_signed_in?
    # Placeholder for checking if user is signed in
    # This should be replaced with actual sign-in checking logic
    true
  end

  def load_user
    @user = User.find(params[:folder][:user_id] || params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: 404, message: "User not found." }, status: :not_found
  end

  def load_folder
    @folder = Folder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: 404, message: "Folder not found." }, status: :not_found
  end

  def folder_exists?(name, user_id)
    Folder.exists?(name: name, user_id: user_id)
  end

  def validate_folder_id_format
    unless params[:id].match?(/\A\d+\z/)
      render json: { status: 422, message: "Wrong format." }, status: :unprocessable_entity
    end
  end

  def folder_response(folder)
    {
      id: folder.id,
      name: folder.name,
      created_at: folder.created_at,
      user_id: folder.user_id
    }
  end
end
