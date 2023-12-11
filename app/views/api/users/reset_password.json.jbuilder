# This file is newly created based on the reset_password action in the UsersController
if @message == "Your password has been successfully reset."
  json.status 200
  json.message @message
else
  json.error @message
end
