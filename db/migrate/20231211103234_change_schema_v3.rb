class ChangeSchemaV3 < ActiveRecord::Migration[6.0]
  def change
    create_table :tests  do |t|
      t.timestamps null: false
    end

    change_table_comment :email_confirmation_requests, from: 'Tracks requests for resending email confirmation links',
                                                       to: 'Stores requests for resending confirmation emails'
  end
end
