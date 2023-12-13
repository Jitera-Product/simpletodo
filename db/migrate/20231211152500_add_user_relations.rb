class AddUserRelations < ActiveRecord::Migration[6.0]
  def change
    # Since the guideline specifies not to touch existing migration files and to create a new one,
    # we are creating a new migration file with a unique timestamp in the filename.

    # Adding new relationships to the users table as per the provided table information.
    # The users table already exists, so we'll be using the `change_table` method to add references.

    change_table :authentication_tokens do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who owns the authentication token'
    end

    change_table :dashboards do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who owns the dashboard'
    end

    change_table :email_confirmation_requests do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user requesting email confirmation'
    end

    change_table :email_confirmations do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who has confirmed their email'
    end

    change_table :password_reset_tokens do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who requested a password reset'
    end

    change_table :todos do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who created the todo'
    end

    change_table :comments do |t|
      t.references :user, foreign_key: true, comment: 'Reference to the user who created the comment'
    end
  end
end
