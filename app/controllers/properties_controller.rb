class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:agent).order(created_at: :desc)
    render json: @properties.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type, :status, :area, :year_built
      ],
      methods: [ :agent_name ]
    )
  end
end
