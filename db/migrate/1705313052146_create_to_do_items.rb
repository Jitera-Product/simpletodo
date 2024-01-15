class CreateToDoItems < ActiveRecord::Migration[5.2]
  def change
    create_table :to_do_items do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.string :status
      t.references :folder, foreign_key: true

      t.timestamps
    end
  end
end
