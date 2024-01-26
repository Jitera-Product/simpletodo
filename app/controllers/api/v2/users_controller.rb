require_relative '../../../services/user_session_service/validate'

module Api
  module V2
    class UsersController < Api::BaseController
      # This is the existing code for other actions in the UsersController
      # ...

      # This is the new code for the validate_session_v2 action
      def validate_session_v2
        session_token = params[:session_token]

        if session_token.blank?
          render json: { error: 'The session token is required.' }, status: :bad_request
          return
        end

        result = UserSessionService::Validate.new(session_token).execute

        if result[:status]
          render json: { message: 'Session token is valid.' }, status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end
    end
  end
end
