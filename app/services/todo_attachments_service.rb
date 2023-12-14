# /app/services/todo_attachments_service.rb
class TodoAttachmentsService
  MAX_FILE_SIZE = 10.megabytes # Example constant, replace with actual value from initializer
  ALLOWED_FORMATS = %w[image/jpeg image/png application/pdf].freeze # Example constant, replace with actual value from initializer
  def process_attachments(todo_id, attachments)
    attachment_ids = []
    errors = []
    attachments.each do |attachment|
      if validate_attachment(attachment)
        file_reference = store_attachment(attachment)
        attachment_record = create_attachment_record(file_reference, todo_id)
        attachment_ids << attachment_record.id
      else
        errors << "Invalid file format or size for #{attachment.original_filename}"
      end
    end
    if errors.any?
      { success: false, errors: errors }
    else
      { success: true, attachment_ids: attachment_ids }
    end
  end
  private
  def validate_attachment(attachment)
    file_size = attachment.size
    file_format = attachment.content_type
    file_size <= MAX_FILE_SIZE && ALLOWED_FORMATS.include?(file_format)
  end
  def store_attachment(attachment)
    # Assuming Active Storage is set up
    blob = ActiveStorage::Blob.create_and_upload!(
      io: attachment,
      filename: attachment.original_filename,
      content_type: attachment.content_type
    )
    blob.signed_id # or blob.key, depending on your needs
  end
  def create_attachment_record(file_reference, todo_id)
    Attachment.create!(
      todo_id: todo_id,
      file: file_reference,
      file_name: File.basename(file_reference)
    )
  end
end
