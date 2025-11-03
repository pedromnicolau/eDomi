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
        :status, :area, :year_built, :agent_id,
        :neighborhood, :zip_code
      ],
      methods: [ :agent_name, :photos_urls, :photos_data ]
    )
  end

  def show
    render json: @property.as_json(
      only: [
        :id, :title, :description, :price, :city, :state,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :address, :property_type, :status, :area, :year_built, :agent_id,
        :neighborhood, :zip_code
      ],
      methods: [ :agent_name, :photos_urls, :photos_data ]
    )
  end

  def create
    # only agents and admins reach here (authorize_create!)
    # não passar os campos de endereço para mass-assignment no Property (evita AssociationTypeMismatch)
    @property = Property.new(property_params.except(
      :uploaded_photos, :remove_photo_blob_ids,
      :address, :neighborhood, :city, :state, :zip_code, :country
    ))

    # atribui o criador como agente do imóvel (agent_id)
    @property.agent = current_user
    if @property.save
      # attach uploaded files diretamente (uma única operação) se presentes
      if property_params[:uploaded_photos].present?
        @property.photos.attach(property_params[:uploaded_photos])
      end

      # sincroniza/ cria endereço associado se houver dados de endereço
      sync_address!(@property, property_params)

      render json: @property.as_json(methods: [ :agent_name, :photos_urls, :photos_data ]).merge({ message: "Imóvel criado com sucesso" }), status: :created
    else
      render json: { errors: @property.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # também excluir campos de endereço no update (endereço será tratado por sync_address!)
    if @property.update(property_params.except(
      :uploaded_photos, :remove_photo_blob_ids,
      :address, :neighborhood, :city, :state, :zip_code, :country
    ))
      # remove attachments indicados (se houver)
      if property_params[:remove_photo_blob_ids].present?
        ids = Array(property_params[:remove_photo_blob_ids]).map(&:to_i)
        @property.photos_attachments.where(blob_id: ids).each(&:purge)
      end

      # attach uploaded files diretamente (não salva o property novamente)
      if property_params[:uploaded_photos].present?
        @property.photos.attach(property_params[:uploaded_photos])
      end

      # sincroniza/ atualiza endereço associado se houver dados de endereço
      sync_address!(@property, property_params)

      render json: @property.as_json(methods: [ :agent_name, :photos_urls, :photos_data ]).merge({ message: "Imóvel atualizado com sucesso" })
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
    params.require(:property).permit(
      :title, :description, :price,
      :property_type, :area, :bedrooms, :bathrooms, :parking_spaces,
      :furnished, :condominium_fee, :iptu, :year_built,
      :address, :neighborhood, :city, :state, :zip_code, :country,
      :status,
      :agent_id,
      uploaded_photos: [], remove_photo_blob_ids: []
    )
  end

  # Sincroniza o Address associado ao Property a partir dos parâmetros permitidos.
  # Mapeamento: params[:address] -> address_line1
  # Se não houver dados mínimos (address_line1, city ou state) a operação é ignorada.
  def sync_address!(property, pp)
    return unless property.persisted?

    # pp pode ser ActionController::Parameters; extrair valores com to_h/[] seguros
    addr_line = pp[:address].to_s.strip if pp[:address]
    city = pp[:city].to_s.strip if pp[:city]
    state = pp[:state].to_s.strip if pp[:state]
    neighborhood = pp[:neighborhood].to_s.strip if pp[:neighborhood]
    zip_code = pp[:zip_code].to_s.strip if pp[:zip_code]
    country = pp[:country].presence || "BR"

    # decidir se há dados suficientes para criar/atualizar
    has_any = [ addr_line, city, state, neighborhood, zip_code ].any? { |v| v.present? }
    return unless has_any

    attrs = {
      address_line1: addr_line.presence || "",
      neighborhood: neighborhood.presence,
      city: city.presence,
      state: state.presence,
      zip_code: zip_code.presence,
      country: country
    }.compact

    # se já existir, atualiza; senão cria (usa create! com resgate de erros silenciado)
    if property.address.present?
      property.address.update(attrs)
    else
      begin
        property.create_address!(attrs)
      rescue => e
        Rails.logger.error("Failed to create address for property_id=#{property.id}: #{e.class} #{e.message}")
        # não interrompe o fluxo de criação do property
      end
    end
  end
end
