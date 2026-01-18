class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum :address_type, { primary: 0, mailing: 1, billing: 2, property: 3 }

  before_validation :normalize_fields

  validates :address_line1, :city, :state, :address_type, presence: true
  validates :address_line1, length: { maximum: 255 }
  validates :address_line2, length: { maximum: 255 }, allow_blank: true
  validates :number, length: { maximum: 20 }, allow_blank: true
  validates :city, length: { maximum: 100 }
  validates :state, length: { maximum: 100 }
  validates :zip_code, length: { maximum: 20 }, allow_blank: true

  def full_address
    parts = [ address_line1 ]
    parts << "nº #{number}" if number.present?
    parts += [ address_line2, city, state, zip_code ].compact.reject(&:blank?)
    parts.join(", ")
  end

  private

  def normalize_fields
    self.address_line1 = address_line1.to_s.strip.presence
    self.address_line2 = address_line2.to_s.strip.presence
    self.number = number.to_s.strip.presence
    self.city = city.to_s.strip.split.map(&:capitalize).join(" ").presence
    self.state = state.to_s.strip.upcase.presence
    self.zip_code = zip_code.to_s.strip.presence
  end
end
