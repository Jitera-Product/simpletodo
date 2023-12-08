json.user do
  json.id @user.id
  json.created_at @user.created_at
  json.updated_at @user.updated_at
  json.session_token @user.session_token
end
