class Api::FoldersController < Api::BaseController
  before_action :authenticate_user!
  before_action :load_user, only: [:create]

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
    @user = User.find(params[:folder][:user_id])
  end

  def folder_exists?(name, user_id)
    Folder.exists?(name: name, user_id: user_id)
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
