# /app/services/todo_attachments_service.rb
class TodoAttachmentsService
  def save_attachments(todo_id, attachments)
    attachments_info = []
    attachments_saved = 0
    attachments.each do |attachment|
      begin
        file_name = FileStorageService.generate_unique_name(attachment.original_filename)
        file_path = FileStorageService.save_file(attachment, file_name)
        Attachment.create!(
          todo_id: todo_id,
          file_path: file_path,
          file_name: attachment.original_filename
        )
        attachments_info << { file_name: attachment.original_filename, file_path: file_path }
        attachments_saved += 1
      rescue => e
        # Handle file upload errors here
        Rails.logger.error "Failed to save attachment: #{e.message}"
      end
    end
    { attachments_saved: attachments_saved, attachments_info: attachments_info }
  end
end
