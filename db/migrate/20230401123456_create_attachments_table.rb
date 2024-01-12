class CreateAttachmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.string :file_path, null: false
      t.references :todo, null: false, foreign_key: true
      t.timestamps
    end
  end
end
