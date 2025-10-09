class Sale < ApplicationRecord
  belongs_to :property
  belongs_to :agent, class_name: "User", foreign_key: :agent_id
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id, optional: true

  has_one :commission, dependent: :destroy

  after_create :create_commission_record!

  private

  def create_commission_record!
    percentage = Rails.configuration.x.edomi.commission_percentage || 5.0
    Commission.create!(
      sale: self,
      agent: agent,
      percentage: percentage,
      value: (sale_price.to_d * percentage.to_d / 100)
    )
  end
end
