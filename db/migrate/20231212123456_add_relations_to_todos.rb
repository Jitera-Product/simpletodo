class AddRelationsToTodos < ActiveRecord::Migration[6.0]
  def change
    # Since the task is to update the ERD and add relations, we are creating a new migration file.
    # The timestamp in the filename should be generated and unique.

    # Adding a foreign key from todos to users
    add_reference :todos, :user, foreign_key: true

    # Adding a foreign key from attachments to todos
    add_reference :attachments, :todo, foreign_key: true

    # Adding a foreign key from todo_categories to todos
    add_reference :todo_categories, :todo, foreign_key: true

    # Adding a foreign key from todo_tags to todos
    add_reference :todo_tags, :todo, foreign_key: true

    # Adding a foreign key from comments to todos
    add_reference :comments, :todo, foreign_key: true
  end
end
