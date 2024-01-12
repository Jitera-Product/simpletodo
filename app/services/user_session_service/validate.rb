
# rubocop:disable Style/ClassAndModuleChildren
class UserSessionService::Validate
  attr_accessor :session_token
  def initialize(session_token)
    @session_token = session_token
  end
  
  def execute
    auth_token = AuthenticationToken.find_by(token: session_token, 'expires_at > ?', Time.current)

    return { status: false, error: 'Invalid or expired session token' } unless auth_token&.expires_at&.future?

    user = User.find_by(id: auth_token.user_id)

    if user.nil? || !user.email_confirmed
      { status: false, error: 'User not found or email not confirmed' }
    else
      { status: true }
    end rescue { status: false, error: 'An unexpected error occurred' }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
