module Api
  class FoldersController < BaseController
    def cancel_creation
      render json: { status: 'cancelled', message: 'Folder creation has been cancelled.' }, status: :ok
    end
  end
end
