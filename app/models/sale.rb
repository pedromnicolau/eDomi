class Sale < ApplicationRecord
  # associações (assumindo users para agent e buyer)
  belongs_to :property
  belongs_to :agent, class_name: "User"
  belongs_to :buyer, class_name: "User"

  # validações
  validates :property_id, :agent_id, :buyer_id, :sale_date, presence: true
  validates :sale_price, presence: true,
                         numericality: { greater_than_or_equal_to: 0 }
end
