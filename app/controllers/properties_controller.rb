class PropertiesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_property, only: [ :show, :update, :destroy ]
  before_action :authorize_create!, only: [ :create ]
  before_action :authorize_modify!, only: [ :update, :destroy ]

  def index
    @properties = Property
                    .where(status: :available)
                    .includes(:agent, :address, photos_attachments: :blob)
                    .order(created_at: :desc)

    render json: @properties.map { |p|
      p.as_json(
        only: [
          :id, :title, :description, :price,
          :bedrooms, :bathrooms, :parking_spaces, :furnished,
          :condominium_fee, :iptu, :address, :property_type,
          :status, :area, :year_built, :agent_id,
          :owner_id, :tenant_id,
          :neighborhood, :zip_code
        ],
        methods: [ :agent_name, :photos_urls, :photos_data ]
      ).merge(
        address: p.address&.address_line1,
        number: p.address&.number,
        neighborhood: p.address&.neighborhood,
        city: p.address&.city,
        state: p.address&.state,
        zip_code: p.address&.zip_code,
        country: p.address&.country
      )
    }
  end

  def show
    render json: @property.as_json(
      only: [
        :id, :title, :description, :price,
        :bedrooms, :bathrooms, :parking_spaces, :furnished,
        :condominium_fee, :iptu, :property_type, :status, :area, :year_built, :agent_id,
        :owner_id, :tenant_id
      ],
      methods: [ :agent_name, :photos_urls, :photos_data ]
    ).merge(
      address: @property.address&.address_line1,
      number: @property.address&.number,
      neighborhood: @property.address&.neighborhood,
      city: @property.address&.city,
      state: @property.address&.state,
      zip_code: @property.address&.zip_code,
      country: @property.address&.country
    )
  end

  def create
    permitted = property_params
    @property = Property.new(permitted.except(
      :uploaded_photos, :remove_photo_blob_ids,
      :address, :number, :neighborhood, :city, :state, :zip_code, :country, :agent_id
    ))

    # regra de atribuição do corretor responsável
    chosen_id = permitted[:agent_id]
    chosen = User.find_by(id: chosen_id) if chosen_id.present?
    if current_user.admin?
      # admin pode escolher qualquer admin ou agente; fallback para ele mesmo
      if chosen && (chosen.admin? || chosen.agent?)
        @property.agent = chosen
      else
        @property.agent = current_user
      end
    elsif current_user.agent?
      # agente pode escolher somente ele mesmo ou um admin
      if chosen && (chosen.admin? || chosen.id == current_user.id)
        @property.agent = chosen
      else
        @property.agent = current_user
      end
    end
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
    permitted = property_params

    # mudança de agente responsável conforme regras
    if permitted.key?(:agent_id)
      new_agent_id = permitted[:agent_id]
      candidate = User.find_by(id: new_agent_id) if new_agent_id.present?
      if current_user.admin?
        if candidate && (candidate.admin? || candidate.agent?)
          @property.agent = candidate unless @property.agent_id == candidate.id
        end
      elsif current_user.agent? && @property.agent_id == current_user.id
        # agente só pode transferir para admin ou manter em si
        if candidate && (candidate.admin? || candidate.id == current_user.id)
          @property.agent = candidate unless @property.agent_id == candidate.id
        end
      end
    end

    if @property.update(permitted.except(
      :uploaded_photos, :remove_photo_blob_ids,
      :address, :number, :neighborhood, :city, :state, :zip_code, :country, :agent_id
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
      :address, :number, :neighborhood, :city, :state, :zip_code, :country,
      :status,
      :agent_id, :owner_id, :tenant_id,
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
    number = pp[:number].to_s.strip if pp[:number]
    city = pp[:city].to_s.strip if pp[:city]
    state = pp[:state].to_s.strip if pp[:state]
    neighborhood = pp[:neighborhood].to_s.strip if pp[:neighborhood]
    zip_code = pp[:zip_code].to_s.strip if pp[:zip_code]
    country = pp[:country].presence || "BR"

    # decidir se há dados suficientes para criar/atualizar
    has_any = [ addr_line, number, city, state, neighborhood, zip_code ].any? { |v| v.present? }
    return unless has_any

    attrs = {
      address_line1: addr_line.presence || "",
      number: number.presence,
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
