if result[:error].present?
  json.error result[:error]
else
  json.status 200
  json.message result[:message]
end
