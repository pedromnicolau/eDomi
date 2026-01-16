class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_privileged!

  # GET /sales.json
  def index
    sales = Sale.joins(:property, :agent).where(properties: { status: "sold" })

    render json: sales.map { |s|
      {
        id: s.id,
        property_title: s.property&.title,
        agent_name: s.agent&.name,
        value: s.sale_price
      }.merge(
        commission: (s.sale_price * 5) / 100
        )
    }
  end
end
