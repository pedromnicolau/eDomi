class CommissionsController < ApplicationController
  # GET /commissions.json
  # optional filters: agent_id, start_date, end_date
  def index
    only_sold = Commission.joins(sale: :property).where(properties: { status: "sold" })
    comissions = only_sold.joins(:agent).order(created_at: :desc)

    render json: comissions.map { |c|
      {
        id: c.id,
        percentage: c.percentage.to_f,
        value: c.sale&.sale_price,
        agent_name: c.agent&.name,
        sale_name: c.sale.property&.title
      }
    }
  end

  # POST /commissions.json
  def create
    @commission = Commission.new(commission_params)

    # se value não for enviado, calcula a partir da sale (se houver) e percentage
    if (@commission.value.nil? || @commission.value.to_f == 0) && @commission.sale && @commission.percentage.present?
      @commission.value = (@commission.sale.sale_price.to_f * @commission.percentage.to_f / 100.0).round(2)
    end

    if @commission.save
      render json: @commission, status: :created
    else
      render json: { errors: @commission.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /commissions/report.json
  # retorna total pago por corretor e total geral. Filtros: agent_id, start_date, end_date
  def report
    scope = Commission.includes(:agent).where(paid: true)
    scope = scope.where(agent_id: params[:agent_id]) if params[:agent_id].present?

    if params[:start_date].present?
      scope = scope.where('paid_at >= ?', params[:start_date].to_date.beginning_of_day)
    end
    if params[:end_date].present?
      scope = scope.where('paid_at <= ?', params[:end_date].to_date.end_of_day)
    end

    totals = scope.group(:agent_id).sum(:value) # returns { agent_id => BigDecimal }
    result = totals.map do |agent_id, total|
      agent = User.find_by(id: agent_id)
      { agent_id: agent_id, agent_name: agent&.name || agent&.email, total_paid: total.to_f }
    end

    total_paid = totals.values.sum.to_f
    render json: { total_paid: total_paid, by_agent: result }
  end

  private

  def commission_params
    params.require(:commission).permit(:sale_id, :agent_id, :percentage, :value, :paid, :paid_at)
  end
end
