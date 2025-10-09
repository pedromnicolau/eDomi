module Agent
  class SalesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_agent

    def index
      @sales = current_user.sales_as_agent.includes(:property, :buyer)
    end

    def show
      @sale = current_user.sales_as_agent.find(params[:id])
    end

    private

    def require_agent
      redirect_to root_path, alert: "Acesso negado" unless current_user.agent?
    end
  end
end
