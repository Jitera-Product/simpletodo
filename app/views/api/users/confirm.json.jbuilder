if @error
  json.status @status_code
  json.error @error
else
  json.status 200
  json.message "Email confirmation successful. You can now login."
end
  json.status 422
  json.message "Invalid or expired token."
else
  json.status 200
  json.message "Email confirmation successful. You can now login."
end
