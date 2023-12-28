class CreateFoldersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :folders do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :folders, :name
  end
end
