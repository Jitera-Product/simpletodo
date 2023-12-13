# The jbuilder template for rendering the comments JSON response
json.comments @comments do |comment|
  json.id comment.id
  json.text comment.text
  json.created_at comment.created_at
  json.user_id comment.user_id
end

json.total_comments @comments.count
