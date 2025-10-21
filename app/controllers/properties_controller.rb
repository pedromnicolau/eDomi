class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_property, only: [ :show, :update, :destroy ]
  before_action :authorize_create!, only: [ :create ]
  before_action :authorize_modify!, only: [ :update, :destroy ]

  def index
    @properties = Property.includes(:agent).order(created_at: :desc)
    render json: @properties.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type, :status, :area, :year_built, :agent_id
      ],
      methods: [ :agent_name ]
    )
  end

  def show
    render json: @property.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type, :status, :area, :year_built, :agent_id
      ],
      methods: [ :agent_name ]
    )
  end

  def create
    # only agents and admins reach here (authorize_create!)
    @property = Property.new(property_params)
    # atribui o criador como agente do imóvel (agent_id)
    @property.agent = current_user
    if @property.save
      render json: @property.as_json(methods: [ :agent_name ]), status: :created
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @property.update(property_params)
      render json: @property.as_json(methods: [ :agent_name ])
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    head :no_content
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def authorize_create!
    unless current_user.admin? || current_user.agent?
      render json: { error: "Não autorizado" }, status: :forbidden
    end
  end

  def authorize_modify!
    return if current_user.admin?
    unless current_user.agent? && @property.agent_id == current_user.id
      render json: { error: "Não autorizado" }, status: :forbidden
    end
  end

  def property_params
    params.require(:property).permit(
      :title, :description, :price, :property_type, :area,
      :bedrooms, :bathrooms, :parking_spaces, :furnished,
      :condominium_fee, :iptu, :year_built, :address, :neighborhood,
      :city, :state, :zip_code, :status
    )
  end
end
