class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :message
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
