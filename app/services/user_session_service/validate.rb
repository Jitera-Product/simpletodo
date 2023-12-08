# rubocop:disable Style/ClassAndModuleChildren
class UserSessionService::Validate
  attr_accessor :session_token
  def initialize(session_token)
    @session_token = session_token
  end
  def execute
    user = User.find_by(session_token: session_token)
    if user.nil?
      { status: false, error: 'Invalid session token' }
    elsif user.session_expired?
      { status: false, error: 'Session token expired' }
    else
      { status: true }
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
