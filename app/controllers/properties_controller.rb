class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_property, only: [ :show, :update, :destroy ]
  before_action :authorize_create!, only: [ :create ]
  before_action :authorize_modify!, only: [ :update, :destroy ]

  def index
    @properties = Property
                    .where(status: :available)
                    .includes(:agent, photos_attachments: :blob)
                    .order(created_at: :desc)
    render json: @properties.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type,
        :status, :area, :year_built, :agent_id
      ],
      methods: [ :agent_name, :photos_urls, :photos_data ]
    )
  end

  def show
    render json: @property.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type, :status, :area, :year_built, :agent_id
      ],
      methods: [ :agent_name, :photos_urls, :photos_data ]
    )
  end

  def create
    # only agents and admins reach here (authorize_create!)
    @property = Property.new(property_params.except(:uploaded_photos, :remove_photo_blob_ids))
    # atribui o criador como agente do imóvel (agent_id)
    @property.agent = current_user
    if @property.save
      # attach uploaded files diretamente (uma única operação) se presentes
      if property_params[:uploaded_photos].present?
        @property.photos.attach(property_params[:uploaded_photos])
      end
      render json: @property.as_json(methods: [ :agent_name, :photos_urls, :photos_data ]), status: :created
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @property.update(property_params.except(:uploaded_photos, :remove_photo_blob_ids))
      # remove attachments indicados (se houver)
      if property_params[:remove_photo_blob_ids].present?
        ids = Array(property_params[:remove_photo_blob_ids]).map(&:to_i)
        @property.photos_attachments.where(blob_id: ids).each(&:purge)
      end

      # attach uploaded files diretamente (não salva o property novamente)
      if property_params[:uploaded_photos].present?
        @property.photos.attach(property_params[:uploaded_photos])
      end

      render json: @property.as_json(methods: [ :agent_name, :photos_urls, :photos_data ])
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
    # buscar com preload para todas as ações que usam @property (show/update/destroy)
    @property = Property.includes(photos_attachments: :blob).find(params[:id])
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

  # permit uploaded_photos and remove_photo_blob_ids as array
  def property_params
    params.require(:property).permit(:title, :description, :price,
      :property_type, :area, :bedrooms, :bathrooms, :parking_spaces,
      :furnished, :condominium_fee, :iptu, :year_built, :address, :neighborhood,
      :city, :state, :zip_code, :status,
      uploaded_photos: [], remove_photo_blob_ids: []
    )
  end
end
