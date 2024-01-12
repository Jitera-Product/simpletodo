class CreateTodoFolders < ActiveRecord::Migration[6.0]
  def change
    create_table :todo_folders do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
