class VisitsController < ApplicationController
  before_action :authenticate_user!

  def create
    property = Property.find_by(id: visit_params[:property_id])
    return render json: { error: "Imóvel não encontrado" }, status: :not_found unless property

    @visit = Visit.new(visit_params.except(:agent_id))
    @visit.agent_id = property.agent_id
    @visit.buyer = current_user

    if @visit.save
      # notificações agora são criadas pelo callback em Visit (after_create)
      render json: @visit, status: :created
    else
      render json: { errors: @visit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:property_id, :agent_id, :scheduled_at, :notes)
  end


  private

  def visit_params
    params.require(:visit).permit(:property_id, :agent_id, :scheduled_at, :notes)
  end
end
