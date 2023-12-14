class TodoPolicy
  attr_reader :user, :todo
  def initialize(user, todo)
    @user = user
    @todo = todo
  end
  # Existing methods...
  # Add a new method to determine if the user has permission to upload attachments
  def upload_attachments?
    # Users can only upload attachments to their own todos
    todo.user_id == user.id
  end
end
