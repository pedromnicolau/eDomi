module Admin
  class PropertiesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_property, only: [ :show, :edit, :update, :destroy ]

    def index
      @properties = Property.all.includes(:agent, :property_photos)
    end

    def show; end

    def new
      @property = Property.new
    end

    def create
      @property = Property.new(property_params)
      if @property.save
        redirect_to admin_property_path(@property), notice: "Imóvel criado com sucesso"
      else
        render :new
      end
    end

    def edit; end

    def update
      if @property.update(property_params)
        redirect_to admin_property_path(@property), notice: "Imóvel atualizado"
      else
        render :edit
      end
    end

    def destroy
      @property.destroy
      redirect_to admin_properties_path, notice: "Imóvel deletado"
    end

    private

    def set_property
      @property = Property.find(params[:id])
    end

    def property_params
      params.require(:property).permit(:title, :description, :price, :property_type,
                                       :area, :bedrooms, :bathrooms, :parking_spaces,
                                       :furnished, :condominium_fee, :iptu,
                                       :year_built, :address, :neighborhood, :city,
                                       :state, :zip_code, :status, :agent_id,
                                       property_photos_attributes: [ :id, :image, :position, :_destroy ])
    end

    def require_admin
      redirect_to root_path, alert: "Acesso negado" unless current_user.admin?
    end
  end
end
