class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  enum :address_type, { primary: 0, mailing: 1, billing: 2, property: 3 }

  validates :address_line1, :city, :state, presence: true
end
