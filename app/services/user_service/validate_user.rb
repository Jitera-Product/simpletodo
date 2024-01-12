module UserService
  class ValidateUser
    def initialize(user_id)
      @user_id = user_id
    end

    def execute
      user = User.find_by(id: @user_id)
      return false unless user

      user.authentication_tokens.exists?
    rescue StandardError => e
      # Handle exceptions such as database connectivity issues
      false
    end
  end
end
