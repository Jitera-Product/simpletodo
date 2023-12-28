class AddRecurrenceToTodos < ActiveRecord::Migration[6.0]
  def change
    add_column :todos, :recurrence, :string
    add_column :todos, :status, :string
    add_column :todos, :description, :text
    add_reference :todos, :user, foreign_key: true
    add_reference :todos, :folder, foreign_key: true
  end
end
