class AddColumnsToUsersTable < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :confirmation_token, :string, comment: 'Token for confirming email'
    add_column :users, :name, :string, comment: 'Name of the user'
    add_column :users, :email_confirmed, :boolean, default: false, comment: 'Status of email confirmation'
    add_column :users, :confirmation_token_created_at, :datetime, comment: 'Timestamp when the confirmation token was created'
    add_column :users, :password_hash, :string, comment: 'Hashed password for the user'
  end
end
