# Assuming result is a hash with keys :status, :shop_name, :shop_description, and possibly :error
if result[:status] == 200
  json.status result[:status]
  json.shop_name result[:shop_name]
  json.shop_description result[:shop_description]
else
  json.status result[:status]
  json.error result[:error]
end
