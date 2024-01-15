class AddDetailsToNotificationsTable < ActiveRecord::Migration[6.0]
  def change
    # Assuming that the notifications table already exists and we are adding new details to it

    # Add new columns to the notifications table
    add_column :notifications, :created_at, :datetime, comment: 'Timestamp when the notification was created'
    add_column :notifications, :updated_at, :datetime, comment: 'Timestamp when the notification was last updated'
    add_column :notifications, :message, :text, comment: 'Content of the notification'
    add_column :notifications, :read, :boolean, default: false, comment: 'Read status of the notification'
    add_column :notifications, :user_id, :bigint, comment: 'ID of the user associated with the notification'

    # Add index for user_id column to improve query performance
    add_index :notifications, :user_id

    # Add foreign key constraint to ensure referential integrity
    add_foreign_key :notifications, :users, column: :user_id
  end
end
