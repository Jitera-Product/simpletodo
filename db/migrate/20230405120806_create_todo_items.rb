class CreateTodoItems < ActiveRecord::Migration[6.0]
  def change
    create_table :todo_items do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.string :status
      t.references :todo_folder, null: false, foreign_key: true

      t.timestamps
    end
  end
end
