if @message.present?
  json.status 200
  json.message @message
else
  json.error 'This to-do item is not found'
end
