# Assuming response is a hash with status and message keys
if response[:status] == 200
  json.status response[:status]
  json.message response[:message]
else
  json.error response[:message]
end
