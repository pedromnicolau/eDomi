class VisitsController < ApplicationController
  before_action :authenticate_user!

  # GET /visits.json
  def index
    scope = Visit.includes(:property, :buyer, :agent).where(status: [ Visit.statuses[:pending], Visit.statuses[:confirmed] ])

    if current_user.nil?
      render json: [], status: :unauthorized and return
    end

    # admins veem tudo
    if current_user.role == "admin" || current_user.role == 2

    elsif current_user.role == "agent" || current_user.role == 1
      scope = scope.where(agent_id: current_user.id)
    else
      # comprador: só as que ele solicitou
      scope = scope.where(buyer_id: current_user.id)
    end

    render json: scope.order(scheduled_at: :asc).map { |v|
      {
        id: v.id,
        property_id: v.property_id,
        property_title: v.property.try(:title),
        scheduled_at: v.scheduled_at,
        buyer_id: v.buyer_id,
        buyer_name: v.buyer.try(:name),
        buyer_email: v.buyer.try(:email),
        agent_id: v.agent_id,
        agent_name: v.agent.try(:name),
        agent_email: v.agent.try(:email),
        notes: v.notes,
        status: v.status
      }
    }
  end

  # POST /visits or /visits.json
  def create
    property = Property.find_by(id: visit_params[:property_id])
    return render json: { error: "Imóvel não encontrado" }, status: :not_found unless property

    @visit = Visit.new(visit_params.except(:agent_id))
    @visit.agent_id = property.agent_id
    @visit.buyer = current_user
    @visit.status = :pending

    if @visit.save
      render json: @visit, status: :created
    else
      render json: { errors: @visit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /visits/:id/accept
  def accept
    @visit = Visit.find(params[:id])
    unless current_user && (current_user.id == @visit.agent_id || current_user.role == "admin" || current_user.role == 2)
      return render json: { error: "Não autorizado" }, status: :forbidden
    end

    if @visit.update(status: :confirmed)
      render json: { success: true, status: @visit.status }, status: :ok
    else
      render json: { error: @visit.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # PATCH /visits/:id/reject
  def reject
    @visit = Visit.find(params[:id])
    unless current_user && (current_user.id == @visit.agent_id || current_user.role == "admin" || current_user.role == 2)
      return render json: { error: "Não autorizado" }, status: :forbidden
    end

    if @visit.update(status: :cancelled)
      render json: { success: true }, status: :ok
    else
      render json: { error: @visit.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:property_id, :agent_id, :scheduled_at, :notes)
  end
end
