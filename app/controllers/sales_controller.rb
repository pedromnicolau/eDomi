class SalesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_sale, only: [ :show, :edit, :update, :destroy ]

  def index
    @sales = Sale.includes(:property, :agent, :buyer)
  end

  def show; end

  def edit; end

  def update
    if @sale.update(sale_params)
      redirect_to admin_sale_path(@sale), notice: "Venda atualizada"
    else
      render :edit
    end
  end

  def destroy
    @sale.destroy
    redirect_to admin_sales_path, notice: "Venda deletada"
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(:property_id, :agent_id, :buyer_id, :sale_price, :sale_date)
  end

  def require_admin
    redirect_to root_path, alert: "Acesso negado" unless current_user.admin?
  end
end
