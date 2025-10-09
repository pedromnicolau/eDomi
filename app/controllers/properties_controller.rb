class PropertiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_access!, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_create!, only: [ :new, :create ]

  def index
    if current_user.admin?
      @properties = Property.includes(:property_photos).all
    elsif current_user.agent?
      @properties = current_user.properties.includes(:property_photos)
    else
      @properties = Property.includes(:property_photos).where(status: "available")
    end
  end

  def show; end

  def new
    @property = current_user.properties.new
  end

  def create
    @property = current_user.properties.new(property_params)
    if @property.save
      redirect_to property_path(@property), notice: "Imóvel criado"
    else
      render :new
    end
  end

  def edit; end

  def update
    if @property.update(property_params)
      redirect_to property_path(@property), notice: "Imóvel atualizado"
    else
      render :edit
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: "Imóvel deletado"
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def authorize_access!
    if current_user.admin?
      nil
    elsif current_user.agent?
      redirect_to properties_path, alert: "Acesso negado" unless @property.agent_id == current_user.id
    else
      if action_name != "show"
        redirect_to properties_path, alert: "Acesso negado"
      else
        redirect_to properties_path, alert: "Acesso negado" unless @property.status == "available"
      end
    end
  end

  def authorize_create!
    unless current_user.admin? || current_user.agent?
      redirect_to properties_path, alert: "Acesso negado"
    end
  end

  def property_params
    params.require(:property).permit(:title, :description, :price, :property_type,
                                     :area, :bedrooms, :bathrooms, :parking_spaces,
                                     :furnished, :condominium_fee, :iptu,
                                     :year_built, :address, :neighborhood, :city,
                                     :state, :zip_code, :status,
                                     property_photos_attributes: [ :id, :image, :position, :_destroy ])
  end
end
