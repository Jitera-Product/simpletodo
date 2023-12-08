json.status 200
json.user do
  json.id @user.id
  json.email @user.email
  json.session_token @user.session_token
  json.dashboard_data @user.dashboard_data
end
