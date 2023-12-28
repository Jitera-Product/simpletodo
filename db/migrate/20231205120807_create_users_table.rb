# This migration is responsible for creating the users table
class CreateUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users, comment: 'Table to store user information' do |t|
      t.string :name, comment: 'The name of the user'
      t.string :email, comment: 'The email address of the user'
      t.datetime :email_verified_at, comment: 'Timestamp when the user email is verified'
      t.string :password, comment: 'The hashed password of the user'
      t.string :remember_token, comment: 'Token used to remember the user for a certain period without asking for credentials'

      t.timestamps null: false
    end

    # Add indexes on columns that are frequently used in searches or joins
    add_index :users, :email, unique: true
  end
end
