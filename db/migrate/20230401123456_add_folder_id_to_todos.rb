class AddFolderIdToTodos < ActiveRecord::Migration[6.0]
  def change
    add_reference :todos, :folder, null: true, foreign_key: true
  end
end
