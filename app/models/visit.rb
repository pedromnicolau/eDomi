class Visit < ApplicationRecord
  belongs_to :property
  belongs_to :buyer, class_name: "User"
  belongs_to :agent, class_name: "User"

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }

  validates :scheduled_at, presence: true
  validates :property, :buyer, :agent, presence: true

  after_commit :create_notifications, on: :create

  after_update_commit :notify_on_status_change, if: :saved_change_to_status?

  private

  def create_notifications
    return unless property && buyer && agent
    begin
      scheduled_str = I18n.l(self.scheduled_at, format: :short) rescue self.scheduled_at.to_s
      # quando criado, a visita começa como "pending" — avisamos anunciante e comprador
      agent_body = "Solicitação de visita para #{scheduled_str} no imóvel \"#{property.title}\". Aguardando sua aprovação."
      buyer_body = "Sua solicitação de visita para #{scheduled_str} no imóvel \"#{property.title}\" foi enviada ao anunciante e está aguardando aprovação."

      Notification.create!(user_id: self.agent_id, title: "Solicitação de visita recebida", body: agent_body, read: false)
      Notification.create!(user_id: self.buyer_id, title: "Solicitação enviada", body: buyer_body, read: false)
    rescue => e
      Rails.logger.error("Falha ao criar notificações para Visit##{self.id}: #{e.message}")
    end
  end

  def notify_on_status_change
    return unless saved_change_to_status?
    begin
      if status == "confirmed"
        scheduled_str = I18n.l(self.scheduled_at, format: :short) rescue self.scheduled_at.to_s
        buyer_body = "Sua visita para #{scheduled_str} no imóvel \"#{property.title}\" foi aceita pelo anunciante."
        Notification.create!(user_id: self.buyer_id, title: "Visita confirmada", body: buyer_body, read: false)
      elsif status == "cancelled"
        scheduled_str = I18n.l(self.scheduled_at, format: :short) rescue self.scheduled_at.to_s
        buyer_body = "Sua solicitação de visita para #{scheduled_str} no imóvel \"#{property.title}\" foi recusada pelo anunciante."
        Notification.create!(user_id: self.buyer_id, title: "Visita recusada", body: buyer_body, read: false)
      end
    rescue => e
      Rails.logger.error("Falha ao notificar mudança de status para Visit##{self.id}: #{e.message}")
    end
  end
end
