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
end
