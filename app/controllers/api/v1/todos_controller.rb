# PATH: /app/controllers/api/v1/todos_controller.rb
class Api::V1::TodosController < ApplicationController
  before_action :doorkeeper_authorize!
  # Other actions ...
  # POST /api/todos/:todo_id/attachments
  def upload_attachments
    todo = Todo.find_by(id: params[:todo_id])
    unless todo
      render json: { error: 'Todo not found.' }, status: :not_found
      return
    end
    authorize todo, :update?
    attachments = params[:attachments]
    if attachments.blank?
      render json: { error: 'No attachments provided.' }, status: :bad_request
      return
    end
    result = process_attachments(todo.id, attachments)
    if result[:errors].empty?
      render json: { status: 201, attachments: result[:attachments] }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end
  private
  def process_attachments(todo_id, attachments)
    # Logic to process and store attachments
    # Should return a hash with :attachments and :errors keys
    # Here we should include the validation for file formats and handle any errors
    uploaded_attachments = []
    errors = []
    attachments.each do |attachment|
      if valid_file_format?(attachment)
        # Process and store the attachment
        # For example, create an Attachment record and store the file
        uploaded_attachment = Attachment.create(todo_id: todo_id, file: attachment)
        uploaded_attachments << uploaded_attachment
      else
        errors << "Invalid file format for #{attachment.original_filename}."
      end
    end
    { attachments: uploaded_attachments.map { |a| a.slice(:id, :file, :todo_id) }, errors: errors }
  end
  def valid_file_format?(attachment)
    # Define valid file formats, e.g., ['image/png', 'application/pdf']
    valid_formats = ['image/png', 'application/pdf']
    valid_formats.include?(attachment.content_type)
  end
  # Other private methods ...
end
