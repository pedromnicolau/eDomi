class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum :address_type, { primary: 0, mailing: 1, billing: 2, property: 3 }

  before_validation :normalize_fields

  validates :address_line1, :city, :state, :address_type, :person, presence: true
  validates :address_line1, length: { maximum: 255 }
  validates :address_line2, length: { maximum: 255 }, allow_blank: true
  validates :city, length: { maximum: 100 }
  validates :state, length: { maximum: 100 }
  validates :zip, length: { maximum: 20 }, allow_blank: true

  def full_address
    [ address_line1, address_line2, city, state, zip ].compact.reject(&:blank?).join(", ")
  end

  private

  def normalize_fields
    self.address_line1 = address_line1.to_s.strip.presence
    self.address_line2 = address_line2.to_s.strip.presence
    self.city = city.to_s.strip.split.map(&:capitalize).join(" ").presence
    self.state = state.to_s.strip.upcase.presence
    self.zip = zip.to_s.strip.presence
  end
end
