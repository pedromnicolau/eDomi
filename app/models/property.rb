class Property < ApplicationRecord
  belongs_to :agent, class_name: "User"
  has_many :property_photos, dependent: :destroy

  enum :property_type, { house: 0, apartment: 1, land: 2, commercial: 3 }
  enum :status, { available: 0, under_offer: 1, sold: 2 }

  validates :title, :price, :address, :city, :state, :agent, presence: true
  validates :bedrooms, :bathrooms, :parking_spaces, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price, :condominium_fee, :iptu, numericality: { greater_than_or_equal_to: 0 }

  def agent_name
    agent&.display_name
  end
end
