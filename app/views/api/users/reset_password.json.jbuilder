if user.errors.present?
  json.status 400
  json.errors user.errors
else
  json.status 200
  json.message "Your password has been reset successfully."
end
