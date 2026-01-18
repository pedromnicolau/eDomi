class Property < ApplicationRecord
  belongs_to :agent, class_name: "User"
  belongs_to :owner, class_name: "Person", optional: true
  belongs_to :tenant, class_name: "Person", optional: true
  has_many :property_photos, dependent: :destroy

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true

  enum :property_type, { house: 0, apartment: 1, land: 2, commercial: 3 }
  enum :status, { available: 0, under_offer: 1, sold: 2 }

  validates :title, :price, :agent, presence: true
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
  after_update_commit :create_sale_on_sold, if: -> { saved_change_to_status? && status == "sold" }

  def create_sale_on_sold
    existing = Sale.where(property_id: id).order(sale_date: :desc).first
    return if existing.present?

    # tenta pegar o último buyer_id da visita
    last_visit = Visit.where(property_id: id).order(scheduled_at: :desc).first
    buyer_id = last_visit&.buyer_id || agent_id

    sale_attrs = {
      property_id: id,
      agent_id: agent_id,
      buyer_id: buyer_id,
      sale_price: price.to_d,
      sale_date: Date.current
    }

    sale = Sale.create(sale_attrs)
    unless sale.persisted?
      Rails.logger.error("Erro ao criar Sale: #{sale.errors.full_messages.join(', ')}")
    end
  end
end
