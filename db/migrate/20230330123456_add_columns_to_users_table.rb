class AddColumnsToUsersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :confirmation_token, :string, comment: 'Token for confirming email'
    add_column :users, :name, :string, comment: 'Name of the user'
    add_column :users, :email_confirmed, :boolean, default: false, comment: 'Status of email confirmation'
    add_column :users, :confirmation_token_created_at, :datetime, comment: 'Timestamp when the confirmation token was created'
    add_column :users, :password_hash, :string, comment: 'Hashed password for the user'

    # Assuming that :session_token and :password columns are related to authentication and should be renamed
    rename_column :users, :session_token, :authentication_token
    rename_column :users, :password, :encrypted_password

    # Assuming that the email column already exists and does not need to be added
    # Assuming that timestamps (created_at and updated_at) already exist and do not need to be added

    # Add indexes for columns that are expected to be queried frequently
    add_index :users, :confirmation_token, unique: true
    add_index :users, :email, unique: true
  end
end
