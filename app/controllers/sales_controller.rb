class SalesController < ApplicationController
  # GET /sales.json
  def index
    sales = Sale.joins(:property, :agent).where(properties: { status: "sold" })

    render json: sales.map { |s|
      {
        id: s.id,
        property_title: s.property&.title,
        agent_name: s.agent&.name,
        value: s.sale_price
      }
    }
  end
end
