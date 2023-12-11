# Assuming result is a hash with keys :status, :message, and possibly :error
if result[:status] == :ok
  json.status 200
  json.message result[:message]
elsif result[:status] == :unprocessable_entity
  json.status 422
  json.error result[:error]
else
  json.status result[:status]
  json.error result[:message]
end
