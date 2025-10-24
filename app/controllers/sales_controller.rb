class SalesController < ApplicationController
  # GET /sales.json
  def index
    # inclui property para evitar N+1
    scope = Sale.includes(:property).order(sale_date: :desc)

    # filtra apenas vendas cujo imóvel esteja com status 'sold'
    sold_status_value = (Property.respond_to?(:statuses) && Property.statuses["sold"]) || 2
    scope = scope.joins(:property).where(properties: { status: sold_status_value })

    render json: scope.map { |s|
      {
        id: s.id,
        sale_price: s.sale_price.to_f,
        sale_date: s.sale_date,
        property: {
          id: s.property&.id,
          title: s.property&.title,
          status: s.property&.status
        },
        agent_id: s.agent_id
      }
    }
  end
end
