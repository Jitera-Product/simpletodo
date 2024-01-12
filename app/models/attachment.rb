class Attachment < ApplicationRecord
  # associations
  belongs_to :todo

  # validations
  validates :file_path, presence: true

  # end for validations

  class << self
  end
end
