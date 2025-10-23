class Visit < ApplicationRecord
  belongs_to :property
  belongs_to :buyer, class_name: "User"
  belongs_to :agent, class_name: "User"

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }

  validates :scheduled_at, presence: true
  validates :property, :buyer, :agent, presence: true

  after_commit :create_notifications, on: :create

  private

  def create_notifications
    return unless property && buyer && agent

    begin
      scheduled_str = I18n.l(self.scheduled_at, format: :short) rescue self.scheduled_at.to_s
      agent_body = "Nova visita agendada para #{scheduled_str} no imóvel \"#{property.title}\"."
      buyer_body = "Visita agendada para #{scheduled_str} com o anunciante \"#{agent.name || agent.email || '—'}\"."

      Notification.create!(user_id: self.agent_id, title: "Nova visita agendada", body: agent_body, read: false)
      Notification.create!(user_id: self.buyer_id, title: "Visita agendada", body: buyer_body, read: false)
    rescue => e
      Rails.logger.error("Falha ao criar notificações para Visit##{self.id}: #{e.message}")
    end
  end
end
