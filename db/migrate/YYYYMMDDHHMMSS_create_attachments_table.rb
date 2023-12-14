class CreateAttachmentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :attachments do |t|
      t.string :file_path, null: false
      t.datetime :created_at, precision: 6, null: false
      t.datetime :updated_at, precision: 6, null: false
      t.references :todo, null: false, foreign_key: true, type: :bigint
      t.string :file, null: false
      t.string :file_name, null: false
    end
  end
end
