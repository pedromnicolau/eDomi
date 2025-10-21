class VisitsController < ApplicationController
  before_action :authenticate_user!

  def create
    property = Property.find_by(id: visit_params[:property_id])
    return render json: { error: "Imóvel não encontrado" }, status: :not_found unless property

    @visit = Visit.new(visit_params.except(:agent_id))
    @visit.agent_id = property.agent_id
    @visit.buyer = current_user

    if @visit.save
      # criar notificações para agent e buyer
      begin
        agent_body = "Nova visita agendada para #{I18n.l(@visit.scheduled_at, format: :short)} no imóvel \"#{property.title}\"."
        buyer_body = "Visita agendada para #{I18n.l(@visit.scheduled_at, format: :short)} com o anunciante \"#{property.agent_name || '—'}\"."

        Notification.create!(user_id: @visit.agent_id, title: "Nova visita agendada", body: agent_body, read: false)
        Notification.create!(user_id: @visit.buyer_id, title: "Visita agendada", body: buyer_body, read: false)
      rescue => e
        Rails.logger.error("Falha ao criar notificações: #{e.message}")
      end

      render json: @visit, status: :created
    else
      render json: { errors: @visit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:property_id, :agent_id, :scheduled_at, :notes)
  end
end
