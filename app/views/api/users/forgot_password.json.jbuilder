if @error.present?
  json.status @error[:status]
  json.message @error[:message]
else
  json.status 200
  json.message "Password reset link has been sent to your email."
end
