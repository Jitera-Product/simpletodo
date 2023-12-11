# Assuming response is a hash with status and message keys
if response[:status] == 200
  json.message 'The email address is valid.'
else
  json.error response[:message]
end
