class PropertiesController < ApplicationController
  before_action :authenticate_user!, only: [ :show, :new, :create, :edit, :update ]

  def index
    @properties = Property.available.includes(:property_photos)
  end

  def show
    @property = Property.find(params[:id])
    @visit = Visit.new
  end

  def new
    @property = Property.new
  end

  def edit
    @property = Property.find(params[:id])
  end

  def create
    @property = Property.new(property_params)
    @property.agent_id = current_user.id
    if @property.save
      redirect_to property_path(@property), notice: "Propriedade cadastrada com sucesso!"
    else
      render :new
    end
  end

  def update
    @property = Property.find(params[:id])

    # Separe as imagens dos demais atributos
    photos_param = params[:property].delete(:photos)

    if @property.update(property_params)
      # Adicione novas imagens sem remover as antigas
      if photos_param.present?
        uploaded_photos = Array(photos_param).reject { |p| p.blank? }
        @property.photos.attach(uploaded_photos) if uploaded_photos.any?
      end
      redirect_to @property, notice: "Propriedade atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property = Property.find(params[:id])
    @property.destroy
    redirect_to properties_path, notice: "Propriedade excluída com sucesso."
  end

  def remove_photo
    @property = Property.find(params[:id])
    photo = @property.photos.find(params[:photo_id])
    photo.purge
    redirect_to edit_property_path(@property), notice: "Imagem removida com sucesso."
  end

  private

  def property_params
    params.require(:property).permit(
      :title, :description, :price, :city, :state, :bathrooms, :bedrooms, :area, :parking_spaces,
      photos: []
    )
  end
end
