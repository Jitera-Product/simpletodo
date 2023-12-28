class AddCategoryIdAndTodoIdToTodoCategories < ActiveRecord::Migration[6.0]
  def change
    add_reference :todo_categories, :category, foreign_key: true
    add_reference :todo_categories, :todo, foreign_key: true
  end
end
