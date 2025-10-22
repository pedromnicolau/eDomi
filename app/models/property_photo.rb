class PropertyPhoto < ApplicationRecord
  # associations
  belongs_to :property

  # validations
  validates :property, presence: true

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :position, presence: true, uniqueness: { scope: :property_id }
end
