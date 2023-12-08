if @error_object.present?
  json.error_object @error_object
else
  json.todo do
    json.id @todo.id
    json.title @todo.title
    json.description @todo.description
    json.due_date @todo.due_date
    json.category @todo.category
    json.priority @todo.priority
    json.recurring @todo.recurring
    json.attachment @todo.attachment
    json.created_at @todo.created_at
    json.updated_at @todo.updated_at
  end
end
