class FolderNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, :blank, message: "can't be blank")
    elsif value.match?(/[^\w\s\-]/)
      record.errors.add(attribute, :invalid_characters, message: "contains invalid characters")
    end
  end
end

ActiveModel::Validations::FolderNameValidator = FolderNameValidator
