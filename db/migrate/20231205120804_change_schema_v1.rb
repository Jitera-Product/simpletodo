class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    # Assuming the primary key type is :bigint and foreign key type is :bigint as well
    primary_key_type = :bigint
    foreign_key_type = :bigint
    create_table :users, id: primary_key_type, comment: 'Table to store user information' do |t|
      t.string :confirmation_token
      t.string :name
      t.boolean :email_confirmed, default: false, null: false
      t.string :email, null: false
      t.datetime :confirmation_token_created_at
      t.string :password_hash
      t.string :username
      t.string :password
      t.timestamps null: false
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :confirmation_token, unique: true
    # Other tables (dashboards, etc.) are not modified as per instructions
  end
end
