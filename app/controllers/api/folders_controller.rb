
module Api
  class FoldersController < BaseController
    def check_name_uniqueness
      user_id = params[:user_id]
      name = params[:name]
      is_unique = !Folder.exists?(user_id: user_id, name: name)
      render json: { is_unique: is_unique }
    end

    def cancel_creation
      render json: { status: 'cancelled', message: 'Folder creation has been cancelled.' }, status: :ok
    end
  end
end
