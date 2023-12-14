class AttachmentSerializer
  def serialize_attachments(attachments)
    attachments.map do |attachment|
      {
        id: attachment.id,
        file_path: attachment.file_path,
        file_name: attachment.file_name,
        created_at: attachment.created_at,
        updated_at: attachment.updated_at
      }
    end
  end
end
