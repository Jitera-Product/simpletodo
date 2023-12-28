class AddNameToTodoTags < ActiveRecord::Migration[6.0]
  def change
    add_column :todo_tags, :name, :string, comment: 'Name of the tag'
  end
end
