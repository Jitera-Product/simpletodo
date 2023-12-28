class AddTodoIdToAttachmentsTable < ActiveRecord::Migration[6.0]
  def change
    add_reference :attachments, :todo, foreign_key: true, comment: 'Reference to the todo item'
  end
end
