# Since the controller specifies a jbuilder template for the show action, we need to create one.
# The file should be located at /app/views/api/todos/show.json.jbuilder

# The following is the new code for the jbuilder template based on the controller's requirements and the provided examples.

json.todo do
  json.id @todo.id
  json.title @todo.title
  json.description @todo.description
  json.due_date @todo.due_date
  json.priority @todo.priority
  json.recurrence @todo.recurrence
  json.category_ids @todo.categories.pluck(:id)
  json.tag_ids @todo.tags.pluck(:id)
  json.attachments @todo.attachments.map { |attachment| url_for(attachment) }
  json.created_at @todo.created_at
  json.updated_at @todo.updated_at
end
