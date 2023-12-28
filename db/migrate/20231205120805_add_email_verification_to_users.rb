class AddEmailVerificationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_verified_at, :datetime, comment: 'Timestamp when the user email is verified'
    add_column :users, :remember_token, :string, comment: 'Token used to remember the user for a certain period without asking for credentials'
    
    # Assuming that the folders table and model already exist, we just need to add the reference
    # If the folders table does not exist, you would need to create it in a separate migration
    add_reference :folders, :user, foreign_key: true, comment: 'Reference to the users table'
  end
end
