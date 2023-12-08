# rubocop:disable Style/ClassAndModuleChildren
class UserService::SignIn
  attr_accessor :email, :password
  def initialize(email, password)
    @email = email
    @password = password
  end
  def execute
    return false unless UserService::ValidateEmail.new(email).execute
    return false unless UserService::CheckEmailExist.new(email).execute
    return false unless UserService::ValidatePassword.new(email, password).execute
    user = User.find_by(email: email)
    session_token = UserService::GenerateSessionToken.new(user.id).execute
    dashboard_data = UserService::GetDashboardData.new(user.id).execute
    { session_token: session_token, dashboard_data: dashboard_data }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
