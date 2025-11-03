class Sale < ApplicationRecord
  # associações (assumindo users para agent e buyer)
  belongs_to :property
  belongs_to :agent, class_name: "User"
  belongs_to :buyer, class_name: "User"

  # validações
  validates :property_id, :agent_id, :buyer_id, :sale_date, presence: true
  validates :sale_price, presence: true,
                         numericality: { greater_than_or_equal_to: 0 }

  after_create_commit :create_commission

  private

  def create_commission
    if Commission.where(agent_id:).exists?
      update_commission
      return
    end
    Commission.create(
      sale_id: id,
      agent_id: agent_id,
      percentage: 5.0,
      value: (sale_price.to_f * 5.0 / 100.0).round(2)
    )
  end

  def update_commission
    commission = Commission.find_by(agent_id:)
    new_value = (commission.value + (sale_price.to_f * (commission.percentage.to_f / 100.0))).round(2)
    commission.update(value: new_value)
  end
end
