if result[:error]
  json.status 422
  json.message result[:error]
else
  json.status 200
  json.message result[:success]
end
