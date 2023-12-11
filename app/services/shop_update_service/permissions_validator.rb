# /app/services/shop_update_service/permissions_validator.rb

class ShopUpdateService::PermissionsValidator
  def self.validate_permissions(user, shop_id)
    # Assuming there is a method 'has_permission?' on the User model that checks for permissions.
    user.has_permission?(:update, shop_id)
  end
end
