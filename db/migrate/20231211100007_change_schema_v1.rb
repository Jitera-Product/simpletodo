class ChangeSchemaV1 < ActiveRecord::Migration[6.0]
  def change
    create_table :email_confirmation_requests, comment: 'Tracks requests for resending email confirmation links' do |t|
      t.datetime :requested_at

      t.timestamps null: false
    end

    create_table :todos, comment: 'Stores todo items created by users' do |t|
      t.text :description

      t.integer :recurrence, default: 0

      t.string :title

      t.integer :priority, default: 0

      t.datetime :due_date

      t.timestamps null: false
    end

    create_table :users, comment: 'Stores user account information' do |t|
      t.string :confirmation_token

      t.string :name

      t.boolean :email_confirmed

      t.string :email

      t.datetime :confirmation_token_created_at

      t.string :password_hash

      t.timestamps null: false
    end

    create_table :todo_categories, comment: 'Associative table to link todos and categories' do |t|
      t.timestamps null: false
    end

    create_table :categories, comment: 'Stores categories that can be assigned to todos' do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :attachments, comment: 'Stores files attached to todos' do |t|
      t.string :file_path

      t.timestamps null: false
    end

    create_table :tags, comment: 'Stores tags that can be assigned to todos' do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :password_reset_tokens, comment: 'Stores password reset tokens for users' do |t|
      t.boolean :used

      t.datetime :expires_at

      t.string :token

      t.timestamps null: false
    end

    create_table :todo_tags, comment: 'Associative table to link todos and tags' do |t|
      t.timestamps null: false
    end

    add_reference :todo_tags, :todo, foreign_key: true

    add_reference :email_confirmation_requests, :user, foreign_key: true

    add_reference :todo_categories, :category, foreign_key: true

    add_reference :todos, :user, foreign_key: true

    add_reference :todo_tags, :tag, foreign_key: true

    add_reference :attachments, :todo, foreign_key: true

    add_reference :password_reset_tokens, :user, foreign_key: true

    add_reference :todo_categories, :todo, foreign_key: true
  end
end
