class ChangeSchemaV5 < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmations, comment: 'Stores email confirmation tokens and their expiration' do |t|
      t.datetime :expires_at

      t.string :token

      t.timestamps null: false
    end

    add_reference :email_confirmations, :user, foreign_key: true
  end
end
