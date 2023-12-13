class AddStatusDescriptionToTodos < ActiveRecord::Migration[6.0]
  def change
    change_table :todos do |t|
      t.integer :status, default: 0, comment: 'The status of the todo item (active, completed, deleted)'
      t.text :description, comment: 'A detailed description of the todo item'
    end
  end
end
