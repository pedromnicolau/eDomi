class Company < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :name, presence: true
end
