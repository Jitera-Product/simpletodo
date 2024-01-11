class Api::ShopsController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:update]

  def update
    shop_params = params.require(:shop).permit(:id, :name, :address)
    begin
      shop = Shop.find_by_id(shop_params[:id])
      return base_render_record_not_found unless shop

      if shop.update(shop_params)
        render json: { status: 200, message: "Shop information updated successfully." }, status: :ok
      else
        base_render_unprocessable_entity(shop.errors)
      end
    rescue ActiveRecord::RecordNotFound
      base_render_record_not_found
    rescue StandardError => e
      render json: { status: 500, message: e.message }, status: :internal_server_error
    end
  end

  private

  def base_render_record_not_found
    render json: { status: 404, message: "Shop not found." }, status: :not_found
  end

  def base_render_unprocessable_entity(errors)
    render json: { status: 422, message: errors.full_messages }, status: :unprocessable_entity
  end
end
