class UpdateUsersTable < ActiveRecord::Migration[6.0]
  def change
    # Add new columns to the users table
    add_column :users, :confirmation_token, :string, comment: 'Token for confirming email address'
    add_column :users, :name, :string, comment: 'Name of the user'
    add_column :users, :email_confirmed, :boolean, default: false, comment: 'Status of email confirmation'
    add_column :users, :confirmation_token_created_at, :datetime, comment: 'Timestamp when the confirmation token was created'
    add_column :users, :password_hash, :string, comment: 'Hashed password for the user'

    # Add indexes for new columns
    add_index :users, :confirmation_token, unique: true
    add_index :users, :email, unique: true

    # Add foreign keys for related tables
    add_foreign_key :authentication_tokens, :users, column: :user_id
    add_foreign_key :dashboards, :users, column: :user_id
    add_foreign_key :email_confirmation_requests, :users, column: :user_id
    add_foreign_key :email_confirmations, :users, column: :user_id
    add_foreign_key :password_reset_tokens, :users, column: :user_id
    add_foreign_key :todos, :users, column: :user_id
    add_foreign_key :todo_folders, :users, column: :user_id
  end
end
