class Property < ApplicationRecord
  enum :property_type, { house: 0, apartment: 1, land: 2, commercial: 3 }
  enum :status, { available: 0, sold: 1, inactive: 2 }

  # accepts_nested_attributes_for :property_photos

  belongs_to :agent, class_name: "User", foreign_key: :agent_id, optional: true

  has_many :property_photos, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_one  :sale, dependent: :nullify
end
