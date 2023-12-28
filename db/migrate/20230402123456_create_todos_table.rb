class CreateTodosTable < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :title
      t.integer :priority
      t.datetime :due_date
      t.string :status
      t.text :description
      t.boolean :recurrence

      t.timestamps
    end

    add_index :todos, :due_date
    add_index :todos, :priority
    add_index :todos, :status

    # Assuming that the attachments, todo_categories, and todo_tags models exist and they have a `todo_id` column
    add_foreign_key :attachments, :todos, column: :todo_id
    add_foreign_key :todo_categories, :todos, column: :todo_id
    add_foreign_key :todo_tags, :todos, column: :todo_id
  end
end
