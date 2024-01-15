class CreateFoldersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :folders do |t|
      t.string :name, null: false
      t.string :color, default: nil
      t.string :icon, default: nil
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
