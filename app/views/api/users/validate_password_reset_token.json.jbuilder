# Assuming response is a hash with status and message keys
if response[:status] == 200
  json.token_valid true
else
  json.token_valid false
  json.error response[:message]
end
