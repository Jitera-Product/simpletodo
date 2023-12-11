module TodoItemService
  class Recover
    def self.execute(todo_item_id)
      todo_item = TodoItem.only_deleted.find(todo_item_id)
      if todo_item.recover
        "To-do item has been successfully recovered from the trash."
      else
        "To-do item could not be recovered."
      end
    rescue ActiveRecord::RecordNotFound
      "This to-do item is not found in trash."
    end
  end
end
