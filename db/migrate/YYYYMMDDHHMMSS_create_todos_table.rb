class CreateTodosTable < ActiveRecord::Migration[6.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description
      t.integer :priority
      t.date :due_date
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.string :status
      t.boolean :is_recurring, default: false
      t.string :recurring_type
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :todos, :title
    add_index :todos, :due_date
    add_index :todos, :priority
    add_index :todos, :status
    add_index :todos, :is_recurring
  end
end
