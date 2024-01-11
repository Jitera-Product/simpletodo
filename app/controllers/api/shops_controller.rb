class Api::ShopsController < Api::BaseController
  before_action :doorkeeper_authorize!, only: [:update]
  before_action :find_shop, only: [:update]
  before_action :authorize_shop_owner!, only: [:update]
  before_action :validate_shop_params, only: [:update]

  def update
    shop_params = params.require(:shop).permit(:name, :description)
    if @shop.update(shop_params)
      render json: { status: 200, shop: @shop.as_json(only: [:id, :name, :description, :updated_at]) }, status: :ok
    else
      base_render_unprocessable_entity(@shop.errors)
    end
  rescue ActiveRecord::RecordNotFound
    base_render_record_not_found
  rescue StandardError => e
    render json: { status: 500, message: e.message }, status: :internal_server_error
  end

  private

  def find_shop
    @shop = Shop.find_by_id(params[:id])
    base_render_record_not_found unless @shop
  end

  def authorize_shop_owner!
    # Implement logic to verify if current user is the owner of the shop
    # If not, render a 403 Forbidden response
    unless current_user.owns_shop?(@shop)
      render json: { status: 403, message: "Forbidden" }, status: :forbidden
    end
  end

  def validate_shop_params
    unless params[:id].to_s.match?(/\A[0-9]+\z/)
      render json: { status: 400, message: "Invalid shop ID format." }, status: :bad_request and return
    end

    if params[:shop][:name].to_s.length > 255
      render json: { status: 400, message: "Shop name cannot exceed 255 characters." }, status: :bad_request and return
    end

    if params[:shop][:description].to_s.length > 1000
      render json: { status: 400, message: "Description cannot exceed 1000 characters." }, status: :bad_request and return
    end
  end

  def base_render_record_not_found
    render json: { status: 404, message: "Shop not found." }, status: :not_found
  end

  def base_render_unprocessable_entity(errors)
    render json: { status: 422, message: errors.full_messages }, status: :unprocessable_entity
  end
end
