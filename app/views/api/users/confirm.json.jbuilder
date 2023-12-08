if result[:error]
  json.status 422
  json.message "Invalid or expired token."
else
  json.status 200
  json.message "Email confirmation successful. You can now login."
end
