module TodoService
  class CancellationValidator
    def self.validate_cancellation(id)
      trash_record = Trash.find_by(id: id)
      return false unless trash_record

      # Assuming there is a permissible time frame for cancellation, e.g., 24 hours
      permissible_time_frame = 24.hours
      return false if trash_record.deleted_at < Time.current - permissible_time_frame

      true
    end
  end
end
