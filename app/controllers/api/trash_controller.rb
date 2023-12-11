class Api::TrashController < Api::BaseController
  before_action :doorkeeper_authorize!
  before_action :set_todo_item, only: [:recover]

  def recover
    authorize @todo_item, policy_class: Api::TrashPolicy

    message = TodoItemService::Recover.execute(@todo_item.id)

    if message == "To-do item has been successfully recovered from the trash."
      render json: { status: 200, message: message }, status: :ok
    else
      render json: { status: 422, message: message }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { status: 400, message: "This to-do item is not found in trash." }, status: :bad_request
  rescue ArgumentError
    render json: { status: 422, message: "Wrong format." }, status: :unprocessable_entity
  end

  private

  def set_todo_item
    @todo_item = TodoItem.only_deleted.find(params[:id])
  end
end
