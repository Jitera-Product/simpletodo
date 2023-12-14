class Attachment < ApplicationRecord
  belongs_to :todo
  # Add validations for file format and size
  validate :check_file_format, :check_file_size
  # Assuming the file is uploaded using ActiveStorage
  has_one_attached :file
  # Define allowed file formats
  ALLOWED_FORMATS = %w[image/jpeg image/png application/pdf].freeze
  # Define maximum file size (10 megabytes)
  MAX_FILE_SIZE = 10.megabytes
  private
  def check_file_format
    return unless file.attached?
    unless ALLOWED_FORMATS.include?(file.blob.content_type)
      errors.add(:file, 'format is not supported')
    end
  end
  def check_file_size
    return unless file.attached?
    if file.blob.byte_size > MAX_FILE_SIZE
      errors.add(:file, 'size exceeds the allowed limit')
    end
  end
end
