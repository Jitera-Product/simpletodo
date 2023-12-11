# Assuming result is a hash with valid and errors keys
if result[:valid]
  json.status 200
  json.message "Email address confirmed successfully."
else
  json.error result[:errors].join(', ')
end
