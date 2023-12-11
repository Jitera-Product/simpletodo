# /app/services/todo_recovery_service/recover.rb
module TodoRecoveryService
  class Recover
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def execute
      trash_entry = Trash.find_by(id: id)
      return 'Trash entry not found' unless trash_entry

      todo_attributes = trash_entry.attributes.except('id', 'created_at', 'updated_at', 'deleted_at')
      Todo.create!(todo_attributes)

      if trash_entry.destroy
        'To-do item has been successfully recovered from the trash.'
      else
        'Failed to delete the entry from the trash.'
      end
    rescue ActiveRecord::RecordNotFound
      'To-do item not found in the trash.'
    rescue ActiveRecord::RecordInvalid => e
      e.message
    rescue StandardError => e
      "An error occurred: #{e.message}"
    end
  end
end
