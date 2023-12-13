# PATH: /db/migrate/20231211152308_add_user_relations.rb
class AddUserRelations < ActiveRecord::Migration[6.0]
  def change
    # Since the user table and other related tables are already created,
    # we only need to add the missing relations as per the requirements.

    # Adding a reference from authentication_tokens to users
    add_reference :authentication_tokens, :user, foreign_key: true

    # Adding a reference from dashboards to users
    add_reference :dashboards, :user, foreign_key: true

    # Adding a reference from email_confirmation_requests to users
    add_reference :email_confirmation_requests, :user, foreign_key: true

    # Adding a reference from email_confirmations to users
    add_reference :email_confirmations, :user, foreign_key: true

    # Adding a reference from password_reset_tokens to users
    add_reference :password_reset_tokens, :user, foreign_key: true

    # Adding a reference from todos to users
    add_reference :todos, :user, foreign_key: true

    # Adding a reference from comments to users
    add_reference :comments, :user, foreign_key: true
  end
end
