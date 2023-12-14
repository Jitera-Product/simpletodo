# /app/services/todo_attachments_service.rb
class TodoAttachmentsService
  MAX_FILE_SIZE = 10.megabytes # Example constant, replace with actual value from initializer
  ALLOWED_FORMATS = %w[image/jpeg image/png application/pdf].freeze # Example constant, replace with actual value from initializer
  def upload_and_store_attachments(todo_id, attachments)
    todo = Todo.find_by(id: todo_id)
    return { status: 400, error: "Todo not found." } unless todo
    attachment_results = process_attachments(todo, attachments)
    if attachment_results[:errors].any?
      { status: 422, errors: attachment_results[:errors] }
    else
      { status: 201, attachments: attachment_results[:attachment_records] }
    end
  end
  private
  def process_attachments(todo, attachments)
    attachment_records = []
    errors = []
    attachments.each do |attachment|
      if validate_attachment(attachment)
        file_reference = store_attachment(attachment)
        attachment_record = create_attachment_record(file_reference, todo.id)
        attachment_records << {
          id: attachment_record.id,
          file: attachment_record.file_name,
          todo_id: attachment_record.todo_id
        }
      else
        errors << "Invalid file format."
      end
    end
    { attachment_records: attachment_records, errors: errors }
  end
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
