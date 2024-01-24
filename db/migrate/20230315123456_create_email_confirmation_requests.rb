class CreateEmailConfirmationRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmation_requests do |t|
      t.integer :user_id
      t.datetime :requested_at

      t.timestamps
    end
    add_index :email_confirmation_requests, :user_id
    add_foreign_key :email_confirmation_requests, :users
  end
end
