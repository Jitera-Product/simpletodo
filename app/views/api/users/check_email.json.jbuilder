# This file is newly created based on the check_email action in the UsersController
json.status result[:status]
if result[:error].present?
  json.error result[:error]
else
  json.available result[:available]
end
