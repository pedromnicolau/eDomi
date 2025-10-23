class VisitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @visits = Visit.includes(:property, :buyer, :agent).all

    render json: @visits.map { |v|
      {
        id: v.id,
        property_id: v.property_id,
        property_title: v.property.try(:title),
        scheduled_at: v.scheduled_at,
        buyer_name: v.buyer.try(:name),
        buyer_email: v.buyer.try(:email),
        agent_name: v.agent.try(:name),
        agent_email: v.agent.try(:email),
        notes: v.notes
      }
    }
  end

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
