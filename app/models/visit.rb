class Visit < ApplicationRecord
  belongs_to :property
  belongs_to :buyer, class_name: "User"
  belongs_to :agent, class_name: "User"

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }

  validates :scheduled_at, presence: true
  validates :property, :buyer, :agent, presence: true
end
