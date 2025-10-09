class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @property = Property.find(params[:property_id])
    @visit = Visit.new
  end

  def create
    @property = Property.find(params[:property_id])
    @visit = @property.visits.new(visit_params)
    @visit.buyer = current_user
    @visit.agent = @property.agent
    @visit.status = :pending

    if @visit.save
      redirect_to property_path(@property), notice: "Visita agendada com sucesso!"
    else
      render :new
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:scheduled_at, :notes)
  end
end
