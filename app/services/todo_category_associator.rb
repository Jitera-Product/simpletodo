# PATH: /app/services/todo_category_associator.rb
class TodoCategoryAssociator
  def associate_categories(todo_id, category_ids)
    associations_created = 0
    category_ids.each do |category_id|
      unless CategoryExistenceValidator.new(category_id).valid?
        raise "Category with id #{category_id} does not exist."
      end
    end
    category_ids.each do |category_id|
      next if TodoCategory.exists?(todo_id: todo_id, category_id: category_id)
      TodoCategory.create!(todo_id: todo_id, category_id: category_id)
      associations_created += 1
    end
    associations_created
  end
end
