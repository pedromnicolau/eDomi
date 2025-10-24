class Property < ApplicationRecord
  belongs_to :agent, class_name: "User"
  has_many :property_photos, dependent: :destroy

  enum :property_type, { house: 0, apartment: 1, land: 2, commercial: 3 }
  enum :status, { available: 0, under_offer: 1, sold: 2 }

  validates :title, :price, :address, :city, :state, :agent, presence: true
  validates :bedrooms, :bathrooms, :parking_spaces, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price, :condominium_fee, :iptu, numericality: { greater_than_or_equal_to: 0 }

  # ActiveStorage attachments
  has_many_attached :photos

  # Retorna caminhos para os blobs; se attachments/blobs forem pré-carregados, não dispara queries adicionais.
  def photos_urls
    return [] unless photos.attached?

    photos.map do |attachment|
      blob = attachment.respond_to?(:blob) ? attachment.blob : attachment
      Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end
  end

  # retorna dados úteis das fotos (blob id, filename, url) para permitir remoção no front
  def photos_data
    return [] unless photos.attached?

    photos.map do |attachment|
      blob = attachment.respond_to?(:blob) ? attachment.blob : attachment
      {
        blob_id: blob.id,
        filename: blob.filename.to_s,
        url: Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
      }
    end
  end

  # include photos_urls and photos_data in JSON output
  def as_json(options = {})
    super(options).merge(
      "photos_urls" => photos_urls,
      "photos_data" => photos_data
    )
  end

  private

  def agent_name
    agent&.display_name
  end

  # novo: cria Sale automaticamente quando imóvel for marcado como 'sold'
  # deve ser executado antes da criação automática da comissão
  after_update_commit :create_sale_on_sold, if: -> { saved_change_to_status? && status == "sold" }
  # já existente (mantive): cria comissão após venda ser garantida
  after_update_commit :create_commission_on_sold, if: -> { saved_change_to_status? && status == "sold" }

  def create_sale_on_sold
    # não criar se já existir venda para este imóvel
    existing = Sale.where(property_id: id).order(sale_date: :desc).first
    return if existing.present?

    # tenta inferir buyer a partir da última visita, se existir
    buyer_id = nil
    last_visit = Visit.where(property_id: id).order(scheduled_at: :desc).first
    buyer_id = last_visit.buyer_id if last_visit && last_visit.buyer_id.present?

    # fallback: usa o agent como buyer para satisfazer constraint NOT NULL (ajuste conforme fluxo real)
    buyer_id ||= agent_id

    sale_attrs = {
      property_id: id,
      agent_id: agent_id,
      buyer_id: buyer_id,
      sale_price: (price || 0).to_d,
      sale_date: Date.current
    }

    Sale.create!(sale_attrs)
  rescue => e
    Rails.logger.error("Property#create_sale_on_sold failed for property_id=#{id}: #{e.class} #{e.message}")
    # não re-raise para não impedir o fluxo de update da property
  end

  def create_commission_on_sold
    # tenta recuperar a venda mais recente deste imóvel
    sale = Sale.where(property_id: id).order(sale_date: :desc).first
    return unless sale && sale.agent && sale.sale_price.present?

    pct = (ENV["DEFAULT_COMMISSION_PERCENTAGE"] || "6.0").to_f
    value = (sale.sale_price.to_f * pct / 100.0).round(2)

    # evita duplicação: cria apenas se não existir comissão para esse sale + agent
    Commission.create_with(value: value, percentage: pct, paid: false).find_or_create_by!(sale: sale, agent: sale.agent)
  rescue => e
    Rails.logger.error("Property#create_commission_on_sold failed for property_id=#{id}: #{e.message}")
  end
end
